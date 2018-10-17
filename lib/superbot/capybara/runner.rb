# frozen_string_literal: true

require 'kommando'

module Superbot
  module Capybara
    class Runner
      def self.run(script)
        new.run(script)
      end

      def run(script)
        create_runner
        runner.in.writeln({ eval: script }.to_json)
      end

      def rerun(script)
        runner.in.writeln({ eval: script }.to_json)
      end

      def kill_session
        runner&.kill
      rescue Timeout::Error
        p # do nothing
      ensure
        @runner = nil
      end

      attr_accessor :script, :runner, :finished

      private

      def create_runner
        return if runner

        gem 'superbot-capybara'

        @runner = Kommando.new "sb-capybara"

        @finished = false

        runner.out.every(/{"type":"ok".*\n/) do
          puts "Test succeed!"
          @finished = true
        end

        runner.out.every(/{"type":"error".*\n/) do
          parsed_error = JSON.parse(runner.out.lines.last, symbolize_names: true)
          puts "Test failed: #{parsed_error[:message]}"
          @finished = true
          if parsed_error[:class].start_with?('Selenium::WebDriver::Error')
            kill_session
            puts "", "ERROR: Seems like browser session has been closed, try to run test again to create new session"
          end
        end

        runner.run_async
      rescue Gem::LoadError
        abort "superbot-capybara not installed"
      end
    end
  end
end
