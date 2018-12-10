# frozen_string_literal: true

require "sinatra/base"
require "sinatra/silent"
require "net/http"

module Superbot
  class Web
    def initialize(webdriver_type: 'cloud', region: nil)
      @sinatra = Sinatra.new
      @sinatra.set :bind, ENV.fetch('SUPERBOT_BIND_ADDRESS', '127.0.0.1')
      @sinatra.set :silent_sinatra, true
      @sinatra.set :silent_webrick, true
      @sinatra.set :silent_access_log, false
      @sinatra.server_settings[:Silent] = true

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

      if defined?(Superbot::Teleport::Web)
        Superbot::Teleport::Web.register(@sinatra, webdriver_type: webdriver_type, region: region)
      end
      Superbot::Cloud::Web.register(@sinatra) if defined?(Superbot::Cloud::Web)
      Superbot::Convert::Web.register(@sinatra) if defined?(Superbot::Convert::Web)
    end

    def self.run!(options = { webdriver_type: 'cloud', region: nil })
      new(options).tap(&:run!)
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
