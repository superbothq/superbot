# frozen_string_literal: true

require "sinatra/base"
require "sinatra/silent"
require "net/http"

require_relative "capybara/convert"
require_relative "capybara/runner"

module Superbot
  class Web
    def initialize(webdriver_type: 'cloud', region: nil)
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

      @webdriver_type = webdriver_type
      webdriver_uri = URI.parse(Superbot.webdriver_endpoint(@webdriver_type))
      @request_settings = {
        host:     webdriver_uri.host,
        port:     webdriver_uri.port,
        path:     webdriver_uri.path
      }
      @region = region

      %w(get post put patch delete).each do |verb|
        @sinatra.send(verb, "/wd/hub/*") do
          begin
            request_path = request.path_info.gsub('/wd/hub', '')
            content_type 'application/json'
            response = instance.remote_webdriver_request(
              verb.capitalize,
              request_path,
              request.query_string,
              request.body,
              instance.incomming_headers(request)
            )
            status response.code
            headers instance.all_headers(response)
            response.body
          rescue StandardError => e
            error_message = "Remote webdriver doesn't responding"
            puts error_message, e
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
          path: @request_settings[:path] + path,
          query: query_string.empty? ? nil : query_string
        )
      )
      req = Net::HTTP.const_get(type).new(uri, new_headers.merge('Content-Type' => 'application/json'))

      request_body = body.read
      if cloud_teleport?
        user_auth_creds = Superbot::Cloud.credentials&.slice(:username, :token)
        req.basic_auth(*user_auth_creds.values) if user_auth_creds

        if @region && creating_session?(type, path)
          parsed_body = JSON.parse(request_body)
          parsed_body['desiredCapabilities']['superOptions'] = { 'region': @region }
          request_body = parsed_body.to_json
        end
      end
      req.body = request_body

      Net::HTTP.new(uri.hostname, uri.port).start do |http|
        http.read_timeout = Superbot.cloud_timeout
        http.request(req)
      end
    end

    def cloud_teleport?
      %w(cloud local_cloud).include?(@webdriver_type)
    end

    def creating_session?(method, path)
      method.casecmp?('post') && path == '/session'
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
