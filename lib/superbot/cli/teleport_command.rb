# frozen_string_literal: true

module Superbot
  module CLI
    class TeleportCommand < Clamp::Command
      include Superbot::Validations

      option ['--browser'], 'BROWSER', "Browser type to use. Can be either local or cloud", default: 'local' do |browser|
        validates_browser_type browser
      end
      option ['--region'], 'REGION', 'Region for remote webdriver'
      option ['-u', '--user'], 'AUTH_USER_NAME', 'Cloud webdriver auth credentials', environment_variable: 'AUTH_USER_NAME', attribute_name: :auth_user
      option ['-p', '--password'], 'AUTH_USER_PASSWORD', 'Cloud webdriver auth credentials', environment_variable: 'AUTH_USER_PASSWORD', attribute_name: :auth_password

      def execute
        @web = Superbot::Web.new(
          webdriver_type: browser,
          auth_user: auth_user,
          auth_password: auth_password
        ).tap(&:run_async_after_running!)

        @chromedriver = Kommando.run_async 'chromedriver --silent --port=9515' if browser == 'local'
        puts "", "🤖 Teleport is active ☁️ "

        $stdin.gets
      rescue
        @chromedriver&.kill
        @web&.quit!
      ensure
        @chromedriver&.kill
        @web&.quit!
      end
    end
  end
end
