require "spec_helper"

RSpec.describe "CLI root" do
  before :each do
    @k = Kommando.new "exe/superbot"
    @k.run
  end

  it "prints usage" do
    expect(@k.out).to include "superbot [OPTIONS] SUBCOMMAND [ARG]"
  end

  it "exits with 0" do
    expect(@k.code).to eq 0
  end
end
