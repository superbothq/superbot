require "spec_helper"

RSpec.describe "CLI version" do

  before :each do
    @k = Kommando.new "exe/superbot version"
    @k.run
  end

  it "prints version" do
    expect(@k.out.chomp).to eq Superbot::VERSION
  end
end
