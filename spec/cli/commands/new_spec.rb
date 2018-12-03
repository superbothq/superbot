require "spec_helper"

RSpec.describe Superbot::CLI::NewCommand do
  before do
    ENV['SUPERBOT_FEAT_PROJECT'] = 'true'
  end

  describe "errors" do
    around do |example|
      FileUtils.mkdir superbot_test_path("existing") unless Dir.exist? superbot_test_path("existing")
      File.write superbot_test_path("existing.file"), ""
      example.call
      FileUtils.rm_r superbot_test_path("existing") if Dir.exist? superbot_test_path("existing")
      FileUtils.rm_r superbot_test_path("existing.file") if File.exist? superbot_test_path("existing.file")
    end

    it do
      @k = superbot "new", superbot_test_path("existing")
      expect(@k.code).to eq 1
      expect(@k.out).to include "directory #{superbot_test_path("existing")} already exists"
    end

    it do
      @k = superbot "new", superbot_test_path("existing.file")
      expect(@k.code).to eq 1
      expect(@k.out).to include "#{superbot_test_path("existing.file")} is an existing file"
    end

    it do
      @k = superbot "new", superbot_test_path("*invalid")
      expect(@k.code).to eq 1
      expect(@k.out).to include "#{superbot_test_path("*invalid")} is not valid name for a directory"
    end
  end

  describe "success" do
    around do |example|
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
      example.call
      FileUtils.rm_r superbot_test_path if Dir.exist? superbot_test_path
    end

    it do
      @k = superbot "new", superbot_test_path
      expect(@k.code).to eq 0
      expect(Dir.exist? superbot_test_path).to be_truthy
      expect(File.exist? File.join(superbot_test_path, "main.rb")).to be_truthy

      contents = File.read File.join(superbot_test_path, "main.rb")
      expect(contents).to eq """visit \"http://example.com\"
"""

      expect(@k.out).to include "🤖 created directory #{superbot_test_path}"
      expect(@k.out).to include "superbot run #{superbot_test_path}"
    end
  end
end
