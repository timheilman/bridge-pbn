require 'spec_helper'

RSpec.describe Bridge::Rank do
  describe ".all" do
    it "has one for each possible rank" do
      expect(described_class.all.map(&:order)).to match_array (2..14).to_a
    end
  end
end
