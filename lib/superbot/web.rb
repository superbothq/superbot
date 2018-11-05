# frozen_string_literal: true

require "sinatra/base"
require "sinatra/silent"
require 'net/http'
require 'selenium-webdriver'

require_relative "capybara/convert"
require_relative "capybara/runner"

module Superbot
  class Web
    def initialize(webdriver_type: 'local', auth_user: nil, auth_password: nil)
      @sinatra = Sinatra.new
      @sinatra.set :bind, "127.0.0.1"
      @sinatra.set :silent_sinatra, true
      @sinatra.set :silent_webrick, true
      @sinatra.set :silent_access_log, false
      instance = self

      @sinatra.before do
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
      end

      @sinatra.options '*' do
        response.headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS,POST'
        response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
      end

      @sinatra.get "/__superbot/v1/ping" do
        "PONG"
      end

      @sinatra.post "/__superbot/v1/convert" do
        converted_script = Superbot::Capybara::Convert.call(request.body.read)
        instance.capybara_runner.run(converted_script)
      end

      webdriver_uri = URI.parse(Superbot.webdriver_endpoint(webdriver_type))
      @auth_user = auth_user
      @auth_password = auth_password
      @request_settings = {
        userinfo: [@auth_user, @auth_password].join(':'),
        host:     webdriver_uri.host,
        port:     webdriver_uri.port,
        path:     webdriver_uri.path
      }

      %w(get post put patch delete).each do |verb|
        @sinatra.send(verb, "/wd/hub/*") do
          begin
            content_type 'application/json'
            response = instance.remote_webdriver_request(
              verb.capitalize,
              request.path_info,
              request.query_string,
              request.body,
              instance.incomming_headers(request)
            )
            status response.code
            headers instance.all_headers(response)

            if %w(cloud local_cloud).include?(webdriver_type) && verb == 'post' && request.path_info == '/wd/hub/session' && response.kind_of?(Net::HTTPSuccess)
              session_id = JSON.parse(response.body)['sessionId']

              puts "Opening screenshots stream..."
              options = Selenium::WebDriver::Chrome::Options.new
              options.add_argument("app=#{Superbot.screenshots_url(webdriver_type, session_id)}")
              options.add_argument('no-sandbox')
              ::Selenium::WebDriver.for :chrome, options: options
            end

            response.body
          rescue
            error_message = "Remote webdriver doesn't responding"
            puts error_message
            halt 500, { message: error_message }.to_json
          end
        end
      end
    end

    def capybara_runner
      @capybara_runner ||= Superbot::Capybara::Runner.new
    end

    def remote_webdriver_request(type, path, query_string, body, new_headers)
      uri = URI::HTTP.build(
        @request_settings.merge(
          path: [@request_settings[:path], path.gsub('wd/hub/', '')].join,
          query: query_string.empty? ? nil : query_string
        )
      )
      req = Net::HTTP.const_get(type).new(uri, new_headers.merge('Content-Type' => 'application/json'))
      req.basic_auth(@auth_user, @auth_password) if @auth_user && @auth_password
      req.body = body.read
      Net::HTTP.new(uri.hostname, uri.port).start do |http|
        http.read_timeout = Superbot.cloud_timeout
        http.request(req)
      end
    end

    def all_headers(response)
      header_list = {}
      response.header.each_capitalized do |k, v|
        header_list[k] = v unless k == "Transfer-Encoding"
      end
      header_list
    end

    def incomming_headers(request)
      request.env.map { |header, value| [header[5..-1].split("_").map(&:capitalize).join('-'), value] if header.start_with?("HTTP_") }.compact.to_h
    end

    def run!
      @sinatra.run_async!
    end

    def run_async_after_running!
      Thread.new do
        @sinatra.run!
      end

      loop do
        break if @sinatra.running?

        sleep 0.001
      end
    end

    def quit!
      @sinatra&.quit!
    end
  end
end
