require "spec_helper"

RSpec.describe Superbot::CLI::RunCommand do
  before do
    ENV['SUPERBOT_FEAT_PROJECT'] = 'true'
    ENV['SUPERBOT_DOMAIN'] = 'localhost:3000'
    ENV['SUPERBOT_URI_SCHEME'] = 'http'
  end

  it_behaves_like "run / dev errors"

  describe "success" do
    around do |example|
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
      example.call
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
    end

    it do
      superbot "new", superbot_test_path
      @k = superbot_new "run", superbot_test_path, "--browser=local"
      @k.run
      expect(@k.out).to include("superbot-capybara not installed")
    end
  end
end
