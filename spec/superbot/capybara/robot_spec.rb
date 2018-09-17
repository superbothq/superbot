require "spec_helper"

RSpec.describe Superbot::Capybara::Robot do
  describe "run" do
    let(:script) do
      [
        "visit 'http://www.example.com'",
        "click_on 'Link'",
        "page.execute_script('window.scrollBy(0,' + (page.execute_script('return document.body.scrollHeight') * 10 / 100).to_s + ')')",
        "page.driver.browser.manage.window.resize_to(1920,1080)"
      ].join('; ')
    end

    context "when sb-capybara installed" do
      let(:kommando) { instance_double(Kommando) }

      it "runs script with sb-capybara" do
        expect_any_instance_of(Object).to receive(:gem).with('superbot-capybara').and_return(true)
        expect(Kommando).to receive(:new).with('sb-capybara').and_return(kommando)
        expect(kommando).to receive_message_chain(:in, :writeln).with({eval: script}.to_json)
        expect(kommando).to receive_message_chain(:out, :once).and_yield
        expect(kommando).to receive(:run_async).and_return(Thread.new { true })
        expect(kommando).to receive(:kill).and_return(true)

        expect { described_class.run(script) }.not_to output("superbot-capybara not installed\n").to_stdout
      end
    end

    context "when superbot-capybara not installed" do
      it 'returns notification' do
        expect { described_class.run(script) }.to output("superbot-capybara not installed\n").to_stdout
      end
    end
  end
end
