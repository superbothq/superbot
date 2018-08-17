require "spec_helper"

RSpec.describe "CLI root" do
  before { @k = superbot "" }

  describe "stdout" do
    it do
      expect(@k.out).to include "superbot [OPTIONS] SUBCOMMAND [ARG]"
    end
  end

  describe "error level" do
    it do
      expect(@k.code).to eq 0
    end
  end
end
