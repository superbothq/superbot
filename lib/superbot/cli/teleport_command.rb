# frozen_string_literal: true

module Superbot
  module CLI
    class TeleportCommand < Clamp::Command
      include Superbot::Validations

      option ['--browser'], 'BROWSER', "Browser type to use. Can be either local or cloud", default: 'cloud' do |browser|
        validates_browser_type browser
      end
      option ['--region'], 'REGION', 'Region for remote webdriver'

      def execute
        @web = Superbot::Web.new(webdriver_type: browser).tap(&:run_async_after_running!)

        @chromedriver = Kommando.run_async 'chromedriver --silent --port=9515' if browser == 'local'
        puts "", "🤖 Teleport is active ☁️ "
        puts "", "Configure your webdriver to http://localhost:4567/wd/hub"

        $stdin.gets
      ensure
        close_teleport
      end

      def close_teleport
        @chromedriver&.kill
        @web&.quit!
      end
    end
  end
end
