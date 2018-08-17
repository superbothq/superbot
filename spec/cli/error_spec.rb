require "spec_helper"

RSpec.describe "CLI errors" do
  shared_examples_for "an error" do
    describe "exit level" do
      it do
        expect(@k.code).to eq 1
      end
    end

    describe "stdout" do
      it do
        expect(@k.out).to include "See: 'superbot --help"
      end
    end
  end

  describe "unknown commands" do
    before { @k = superbot "unknown" }
    it_behaves_like "an error"

    describe "stdout" do
      it do
        expect(@k.out).to include "No such sub-command"
      end
    end
  end

  describe "unknown options" do
    before { @k = superbot "--unknown" }
    it_behaves_like "an error"

    describe "stdout" do
      it do
        expect(@k.out).to include "Unrecognised option '--unknown'"
      end
    end
  end
end
