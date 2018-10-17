# frozen_string_literal: true

module Superbot
  module Capybara
    class Convert
      def initialize(json)
        @json = JSON.parse(json, symbolize_names: true)
      end

      def self.call(json)
        new(json).call
      end

      def call
        converted_json
      end

      attr_accessor :json

      private

      def convert_action(action)
        case action[:type]
        when 'visit'      then "visit '#{action[:url]}'"
        when 'click'      then "click_on '#{action[:selector]}'"
        when 'scroll'     then
          "page.execute_script('window.scrollBy(0,' + (page.execute_script('return document.body.scrollHeight') * #{action[:amountPercent]} / 100).to_s + ')')"
        when 'resolution' then "page.driver.browser.manage.window.resize_to(#{action[:resolution].join(',')})"
        when 'has-text'   then "page.assert_text('#{action[:text]}')"
        end
      end

      def converted_json
        return json.map { |action| convert_action(action) }.join('; ') if json.is_a?(Array)
        return convert_action(json) if json.is_a?(Hash)
      end
    end
  end
end
