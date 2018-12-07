# frozen_string_literal: true

require "sinatra/base"
require "sinatra/silent"
require "net/http"

module Superbot
  class Web
    def initialize
      @sinatra = Sinatra.new
      @sinatra.set :bind, ENV.fetch('SUPERBOT_TELEPORT_BIND_ADDRESS', '127.0.0.1')
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
    end

    def run_async!
      @sinatra.run_async!
    end

    def run!
      @sinatra.run!
    end

    def register(extension, options = nil)
      options && extension.register(@sinatra, options) || extension.register(@sinatra)
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
