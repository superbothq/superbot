# frozen_string_literal: true

module Superbot
  module Capybara
    class Runner
      def initialize(script)
        @script = script
      end

      def self.run(*args)
        new(*args).run
      end

      def run
        run_script
      end

      private

      attr_accessor :script

      def run_script
        gem 'superbot-capybara'

        k = Kommando.new "sb-capybara"
        k.in.writeln({ eval: script }.to_json)

        finished = false

        k.out.once(/{"type":"ok".*\n/) do
          puts "Test succeed"
          finished = true
        end

        k.out.once(/{"type":"error".*\n/) do
          begin
            parsed_error = JSON.parse(k.out.lines.last, symbolize_names: true)
            error_message = parsed_error[:message]
            puts "Test failed with #{error_message}"
          end
          finished = true
        end

        k.run_async

        loop do
          break if finished

          sleep 0.001
        end

        begin
          k.kill
        rescue Timeout::Error
          p # do nothing
        end
      rescue Gem::LoadError
        puts "superbot-capybara not installed"
      end
    end
  end
end
