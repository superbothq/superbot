require "spec_helper"

RSpec.describe Superbot::CLI::TeleportCommand do
  describe "teleport" do
    before do
      ENV['SUPERBOT_FEAT_PROJECT'] = 'true'
      ENV['SUPERBOT_FEAT_TELEPORT'] = 'true'
      ENV['SUPERBOT_DOMAIN'] = 'localhost:3000'
      ENV['SUPERBOT_URI_SCHEME'] = 'http'
    end

    around do |example|
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
      example.call
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
    end

    it "closes teleport with control+c interrupt" do
      @k = superbot_new "teleport --browser=local"

      success = false
      @k.out.once(/Press \[control\+c\] to close teleport/) do
        success = true
        Process.kill('INT', @k.instance_variable_get(:@pid))
      end

      @k.run
      expect(success).to be_truthy
    end

    it "runs the local webserver" do
      @k = superbot_new "teleport --browser=local"
      @k.run_async
      wait_web

      body = http_get "http://127.0.0.1:4567/__superbot/v1/ping"
      Process.kill('INT', @k.instance_variable_get(:@pid))
      @k.kill
      expect(body).to eq "PONG"
    end

    it "converts" do
      @k = superbot_new "teleport --browser=local"
      @k.run_async
      wait_web

      payload = [{ id: 123, type: 'visit', url: 'http://www.example.com' }]

      response = http_post_json "http://127.0.0.1:4567/__superbot/v1/convert", payload
      Process.kill('INT', @k.instance_variable_get(:@pid))
      @k.kill

      expect(response.body).to match "superbot-capybara not installed"
    end

    it "runs test through the teleport" do
      superbot "new", superbot_test_path

      @teleport = superbot_new "teleport --browser=local"
      @teleport.run_async
      wait_web

      @test = Kommando.run("ruby ./#{superbot_test_path}/main.rb")
      expect(@teleport.out).not_to include 'Error'

      @test.kill
      Process.kill('INT', @teleport.instance_variable_get(:@pid))
      @teleport.kill
    end
  end
end
