# frozen_string_literal: true

require "superbot/cloud/cli/cloud/validations"

module Superbot
  module CLI
    class TeleportCommand < Clamp::Command
      include Superbot::Validations
      include Superbot::Cloud::Validations

      option ['--browser'], 'BROWSER', "Browser type to use. Can be either local or cloud", default: 'cloud' do |browser|
        validates_browser_type browser
      end
      option ['--region'], 'REGION', 'Region for remote webdriver'

      def execute
        require_login unless browser == 'local'

        @web = Superbot::Web.new(webdriver_type: browser, region: region)
        @web.run_async_after_running!

        @chromedriver = Kommando.run_async 'chromedriver --silent --port=9515' if browser == 'local'

        puts "", "🤖 Teleport is open ☁️ "
        puts "", "Configure your webdriver to http://localhost:4567/wd/hub"
        puts "", "Press [control+c] to close teleport"

        handle_keyboard_interrupt
      ensure
        close_teleport
      end

      def handle_keyboard_interrupt
        @interrupted = false

        trap "SIGINT" do
          puts
          puts "Command killed by keyboard interrupt"
          @interrupted = true
          exit 130
        end

        loop do
          break if @interrupted
        end
      end

      def close_teleport
        @chromedriver&.kill
        @web&.quit!
      end
    end
  end
end
