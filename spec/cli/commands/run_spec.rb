require "spec_helper"

RSpec.describe Superbot::CLI::RunCommand do
  describe "errors" do
    around do |example|
      FileUtils.mkdir "__test_empty_dir" unless Dir.exist? "__test_empty_dir"
      example.call
      FileUtils.rm_r "__test_empty_dir" if Dir.exist? "__test_empty_dir"
    end

    it do
      @k = superbot "run __test_nonexisting_dir"
      expect(@k.code).to eq 1
      expect(@k.out).to include "directory __test_nonexisting_dir does not exist"
    end

    it do
      @k = superbot "run __test_empty_dir"
      expect(@k.code).to eq 1
      expect(@k.out).to include "file __test_empty_dir/main.rb does not exist"
    end
  end

  describe "success" do
    around do |example|
      FileUtils.rm_r "__test" if Dir.exist? "__test"
      example.call
      FileUtils.rm_r "__test" if Dir.exist? "__test"
    end

    it do
      superbot "new __test"
      @k = superbot "run __test"
      expect(@k.code).to eq 0
    end
  end
end
