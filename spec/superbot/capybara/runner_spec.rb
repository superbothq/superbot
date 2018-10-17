require "spec_helper"

RSpec.describe Superbot::Capybara::Runner do
  describe "run" do
    let(:script) do
      "visit 'http://www.example.com'"
    end

    context "when sb-capybara installed" do
      let(:runner) { described_class.new }

      context "when valid capybara script" do
        it "succesfully runs script with sb-capybara" do
          expect do
            runner.run(script)
            sleep 2
          end.to output("Test succeed!\n").to_stdout
          runner.kill_session
        end
      end

      context "when invalid script" do
        it "fails to execute script" do
          expect do
            runner.run('invalid')
            sleep 1
          end.to output(/Test failed.*/).to_stdout
          runner.kill_session
        end
      end
    end

    context "when superbot-capybara not installed" do
      it 'returns notification' do
        expect_any_instance_of(Object).to receive(:gem).with('superbot-capybara').and_raise(Gem::LoadError)
        expect { described_class.run(script) }.to output("superbot-capybara not installed\n").to_stdout
      end
    end
  end
end
