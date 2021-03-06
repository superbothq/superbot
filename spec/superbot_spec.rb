require "spec_helper"

RSpec.describe Superbot do
  it "has a version number" do
    expect(Superbot::VERSION).to be_a String
  end

  it do
    expect(Superbot.test_run?).to be_truthy
  end

  describe '.webdriver_endpoint' do
    it "returns correct webdriver url" do
      {
        cloud: "https://webdriver.superbot.cloud",
        local: "http://127.0.0.1:9515",
        local_cloud: "http://localhost:3200"
      }.each do |type, url|
        expect(Superbot.webdriver_endpoint(type)).to eq(url)
      end
    end
  end

  describe '.cloud_timeout' do
    subject { Superbot.cloud_timeout }

    it { is_expected.to eq(2000) }
  end
end
