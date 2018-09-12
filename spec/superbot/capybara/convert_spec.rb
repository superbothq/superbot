require "spec_helper"

RSpec.describe Superbot::Capybara::Convert do
  describe "call" do
    it 'converts json to capybara syntax' do
      json = [
        { id: 1, type: 'visit', url: 'http://www.example.com' },
        { id: 2, type: 'click', selector: 'Link' },
        { id: 3, type: 'scroll', amountPercent: 10 },
        { id: 4, type: 'resolution', resolution: [1920, 1080] }
      ].to_json

      converted_json = described_class.call(json)

      expect(converted_json).to eq(
        [
          "visit 'http://www.example.com'",
          "click_on 'Link'",
          "page.execute_script('window.scrollBy(0,' + (page.execute_script('return document.body.scrollHeight') * 10 / 100).to_s + ')')",
          "page.driver.browser.manage.window.resize_to(1920,1080)"
        ]
      )
    end
  end
end
