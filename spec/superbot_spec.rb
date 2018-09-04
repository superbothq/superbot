RSpec.describe Superbot do
  it "has a version number" do
    expect(Superbot::VERSION).to be_a String
  end

  it do
    expect(Superbot.test_run?).to be_truthy
  end
end
