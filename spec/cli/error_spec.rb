
require "spec_helper"

RSpec.describe "CLI errors" do

  shared_examples_for "an error" do
    it "exits with 1" do
      expect(@k.code).to eq 1
    end

    it "offers help" do
      expect(@k.out).to include "superbot --help"
    end
  end

  describe "unknown commands" do
    before :each do
      @k = Kommando.new "exe/superbot unknown"
      @k.run
    end

    it_behaves_like "an error"

    it "prints help" do
      expect(@k.out).to include "No such sub-command"
    end
  end

  describe "unknown options" do
    before :each do
      @k = Kommando.new "exe/superbot --unknown"
      @k.run
    end

    it_behaves_like "an error"

    it "prints help" do
      expect(@k.out).to include "Unrecognised option"
    end
  end
end
