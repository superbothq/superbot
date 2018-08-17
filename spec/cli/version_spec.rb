require "spec_helper"

RSpec.describe "CLI version" do

  before { @k = superbot "version" }

  describe "stdout" do
    it do
      expect(@k.out).to eq "#{Superbot::VERSION}\r\n"
    end
  end
end
