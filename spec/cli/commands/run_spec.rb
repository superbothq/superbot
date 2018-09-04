require "spec_helper"

RSpec.describe Superbot::CLI::RunCommand do
  it_behaves_like "run / dev errors"

  describe "success" do
    around do |example|
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
      example.call
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
    end

    it do
      superbot "new", superbot_test_path
      @k = superbot_new "run", superbot_test_path

      success = false
      @k.out.once /Press enter to exit/ do
        success = true
        @k.in.writeln ""
      end

      @k.run
      expect(success).to be_truthy
    end

    it do
      superbot "new", superbot_test_path
      @k = superbot_new "run", superbot_test_path
      @k.run_async
      wait_web

      body = http_get "http://127.0.0.1:4567/__superbot/v1/ping"
      @k.kill
      expect(body).to eq "PONG"
    end

    it "converts" do
      superbot "new", superbot_test_path
      @k = superbot_new "run", superbot_test_path
      @k.run_async
      wait_web

      payload = { id: 123, type: 'visit', url: 'http://www.example.com' }

      response = http_post_json "http://127.0.0.1:4567/__superbot/v1/convert", payload
      @k.kill

      expect(response.body).to match "visit 'http://example.com'"
    end
  end
end
