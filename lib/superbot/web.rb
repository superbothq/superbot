# frozen_string_literal: true

require "sinatra/base"
require "sinatra/silent"
require "net/http"

module Superbot
  class Web
    DEFAULT_OPTIONS = { webdriver_type: 'cloud' }.freeze

    def initialize(teleport_options = {})
      @sinatra = Sinatra.new
      @sinatra.set :bind, ENV.fetch('SUPERBOT_BIND_ADDRESS', '127.0.0.1')
      @sinatra.set :silent_sinatra, true
      @sinatra.set :silent_webrick, true
      @sinatra.set :silent_access_log, false
      @sinatra.server_settings[:Silent] = true

      @sinatra.set :teleport_options, DEFAULT_OPTIONS.merge(teleport_options)
      @sinatra.set :webdriver_url, Superbot.webdriver_endpoint(@sinatra.settings.teleport_options[:webdriver_type])

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

      @sinatra.register Superbot::Teleport::Web if defined?(Superbot::Teleport::Web)
      @sinatra.register Superbot::Cloud::Web if defined?(Superbot::Cloud::Web)
      @sinatra.register Superbot::Convert::Web if defined?(Superbot::Convert::Web)
    end

    def self.run!(teleport_options = {})
      new(teleport_options).tap(&:run!)
    end

    def run_async!
      @sinatra.run_async!
    end

    def run!
      @sinatra.run!
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
