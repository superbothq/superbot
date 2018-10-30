# frozen_string_literal: true

module Superbot
  module CLI
    class RunCommand < Clamp::Command
      include Superbot::Validations

      parameter "PATH", "project directory" do |path|
        validates_project_path path
      end

      option ['--browser'], 'BROWSER', "Browser type to use. Can be either local or cloud", default: 'local' do |browser|
        validates_browser_type browser
      end
      option ['--region'], 'REGION', 'Region for remote webdriver'
      option ['--auth-token'], 'AUTH_TOKEN', 'Cloud webdriver auth credentials', environment_variable: 'CLOUD_DRIVER_AUTH_TOKEN'

      def execute
        script = File.read(File.join(path, 'main.rb'))

        webdriver_proxy = Superbot::Web.new(webdriver_endpoint: Superbot.webdriver_endpoint(browser), auth_token: auth_token)
        webdriver_proxy.run_async_after_running!
        puts "🤖 active"

        chromedriver = Kommando.run_async 'chromedriver --silent --port=9515' if browser == 'local'

        capybara_runner = Superbot::Capybara::Runner.new(browser: browser, region: region)
        capybara_runner.run(script)

        puts capybara_runner.test_result
        puts "Press ENTER to exit"

        $stdin.gets
      ensure
        chromedriver&.kill
        webdriver_proxy&.quit!
        capybara_runner&.kill_session
      end
    end
  end
end
