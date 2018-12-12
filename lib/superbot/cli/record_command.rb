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
        options = ::Selenium::WebDriver::Chrome::Options.new
        options.add_argument("app=about:blank")
        options.add_argument("no-sandbox")
        options.add_extension(File.join(File.dirname(__dir__), '../..', 'bin', 'superside.crx'))
        browser = ::Selenium::WebDriver.for :chrome, options: options

        # close browser window when extension is loaded
        sleep 1
        browser.close
      end
    end
  end
end
