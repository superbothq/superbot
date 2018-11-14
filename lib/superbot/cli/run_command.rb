# frozen_string_literal: true

module Superbot
  module CLI
    class RunCommand < Clamp::Command
      include Superbot::Validations

      parameter "PATH", "project directory" do |path|
        validates_project_path path
      end

      option ['--browser'], 'BROWSER', "Browser type to use. Can be either local or cloud", default: 'cloud' do |browser|
        validates_browser_type browser
      end
      option ['--region'], 'REGION', 'Region for remote webdriver'

      def execute
        script = File.read(File.join(path, 'main.rb'))

        @teleport = Thread.new do
          Superbot::CLI::TeleportCommand.run(nil, ARGV[2..-1], context)
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
