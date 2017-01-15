require 'spec_helper'

RSpec.describe Bridge::Rank do
  describe ".all" do
    it "has one for each possible rank" do
      expect(described_class.all.map(&:order)).to match_array (2..14).to_a
    end
  end
  describe "#pretty_print" do
    it "passes the call through" do
      pp = double
      expect(pp).to receive(:pp).with('#<Bridge::Rank ace>')
      described_class.all.first.pretty_print pp
    end
  end
  describe ".initialize" do
    it "throws an error" do
      expect {subject.initialize}.to raise_error(NoMethodError, /Cannot initialize/)
    end
  end
end
