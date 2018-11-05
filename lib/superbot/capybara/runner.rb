# frozen_string_literal: true

require 'kommando'

module Superbot
  module Capybara
    class Runner
      def initialize(browser: :local, region: nil)
        @browser = browser
        @region = region
      end

      def self.run(script, browser: :local, region: nil)
        new(browser: browser, region: region).run(script)
      end

      def run(script)
        puts "Attaching to #{browser} browser..."
        create_runner
        puts "Running test..."
        runner.in.writeln({ eval: script }.to_json)
        wait_for_finish
      end

      def kill_session
        runner&.kill
      rescue Timeout::Error
        p # do nothing
      ensure
        @runner = nil
      end

      def wait_for_finish
        loop do
          if finished
            @finished = false
            break
          end

          sleep 0.1
        end
      end

      attr_accessor :script, :runner, :finished, :test_result, :browser, :region

      private

      def create_runner
        @finished = false

        return if runner

        gem 'superbot-capybara'

        @runner = Kommando.new "sb-capybara"

        runner.out.every(/{"type":"ok".*\n/) do
          @test_result = "Test succeed!"
          @finished = true
        end

        runner.out.every(/{"type":"error".*\n/) do
          parsed_error = begin
                           JSON.parse(runner.out.lines.last, symbolize_names: true)
                         rescue JSON::ParseError
                           { message: runner.out.lines.last }
                         end
          @test_result = "Test failed: #{parsed_error[:message]}"
          @finished = true

          case parsed_error[:class]
          when "Selenium::WebDriver::Error::WebDriverError", "Selenium::WebDriver::Error::NoSuchWindowError"
            kill_session
            puts "", "Seems like browser session has been closed, try to run test again to create new session"
          when "Selenium::WebDriver::Error::ServerError"
            kill_session
            abort "Remote browser error: #{parsed_error[:message]}"
          else
            puts parsed_error[:message]
          end
        end

        runner.run_async

        runner.in.writeln({ eval: webdriver_config }.to_json)
        wait_for_finish
      rescue Gem::LoadError
        abort "superbot-capybara not installed"
      end

      def webdriver_config
        <<-WEBDRIVER_CONFIG
          ::Capybara.register_driver :chrome_remote do |app|
            webdriver_capabilities = ::Selenium::WebDriver::Remote::Capabilities.chrome(
              chromeOptions: {
                'args' => [
                  'no-sandbox',
                  'no-default-browser-check',
                  'disable-infobars',
                  'app=about:blank',
                ]
              },
              superOptions: #{region ? { region: region } : {}}
            )

            webdriver_http_client = ::Selenium::WebDriver::Remote::Http::Default.new.tap do |client|
              client.read_timeout = #{Superbot.cloud_timeout}
              client.open_timeout = #{Superbot.cloud_timeout}
            end

            ::Capybara::Selenium::Driver.new(
              app,
              browser: :chrome,
              desired_capabilities: webdriver_capabilities,
              http_client: webdriver_http_client,
              url: 'http://127.0.0.1:4567/wd/hub'
            )
          end
          ::Capybara.current_driver = :chrome_remote
        WEBDRIVER_CONFIG
      end
    end
  end
end
