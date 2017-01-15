require 'spec_helper'
RSpec.describe Bridge::Player do
  describe(".initialize") do
    let(:hand) { double }
    subject(:player) { described_class.new(hand) }
    it "is indeed a Player" do
      expect(player).to be_a(Bridge::Player)
    end
  end
end
