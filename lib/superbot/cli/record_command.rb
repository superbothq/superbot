# frozen_string_literal: true

require 'selenium-webdriver'

module Superbot
  module CLI
    class RecordCommand < Clamp::Command
      def execute
        open_superside

        puts "Press [enter] to exit"

        $stdin.gets
      end

      private

      def open_superside
        profile = Selenium::WebDriver::Chrome::Profile.new
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument("app=about:blank")
        options.add_argument("no-sandbox")
        options.add_argument("force-dev-mode-highlighting")
        profile.add_extension(File.join(File.dirname(__dir__), '../..', 'bin', 'superside.crx'))

        @superside = Selenium::WebDriver.for :chrome, options: options, profile: profile
      end
    end
  end
end
