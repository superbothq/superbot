require "spec_helper"

RSpec.describe Superbot::CLI::NewCommand do
  describe "errors" do
    around do |example|
      FileUtils.mkdir "__test_existing" unless Dir.exist? "__test_existing"
      File.write "__test_existing.file", ""
      example.call
      FileUtils.rm_r "__test_existing" if Dir.exist? "__test_existing"
      FileUtils.rm_r "__test_existing.file" if File.exist? "__test_existing.file"
    end

    it do
      @k = superbot "new __test_existing"
      expect(@k.code).to eq 1
      expect(@k.out).to include "directory __test_existing already exists"
    end

    it do
      @k = superbot "new __test_existing.file"
      expect(@k.code).to eq 1
      expect(@k.out).to include "__test_existing.file is an existing file"
    end

    it do
      @k = superbot "new __test*invalid"
      expect(@k.code).to eq 1
      expect(@k.out).to include "__test*invalid is not valid name for a directory"
    end
  end

  describe "success" do
    around do |example|
      FileUtils.rm_r "__test" if Dir.exist? "__test"
      example.call
      FileUtils.rm_r "__test" if Dir.exist? "__test"
    end

    it do
      @k = superbot "new __test"
      expect(@k.code).to eq 0
      expect(Dir.exist? "__test").to be_truthy
      expect(File.exist? "__test/main.rb").to be_truthy

      contents = File.read "__test/main.rb"
      expect(contents).to eq """visit \"example.com\"
"""

      expect(@k.out).to include "🤖 created directory __test"
      expect(@k.out).to include "superbot run __test"
    end
  end
end
