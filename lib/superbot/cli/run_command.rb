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
      option ['-u', '--user'], 'AUTH_USER_NAME', 'Cloud webdriver auth credentials', environment_variable: 'AUTH_USER_NAME', attribute_name: :auth_user
      option ['-p', '--password'], 'AUTH_USER_PASSWORD', 'Cloud webdriver auth credentials', environment_variable: 'AUTH_USER_PASSWORD', attribute_name: :auth_password

      def execute
        script = File.read(File.join(path, 'main.rb'))

        @teleport = Thread.new do
          Superbot::CLI::TeleportCommand.run(nil, ARGV[2..-1], context)
        rescue => e
          abort e.message
        end

        @capybara_runner = Superbot::Capybara::Runner.new(browser: browser, region: region)
        @capybara_runner.run(script)
        puts @capybara_runner.test_result

        puts "Press ENTER to exit"

        $stdin.gets
      ensure
        @teleport&.kill
        @capybara_runner&.kill_session
      end
    end
  end
end
