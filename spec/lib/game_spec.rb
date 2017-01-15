require 'spec_helper'


RSpec.describe Bridge::Game do
  subject(:game) { described_class.random }
  describe ".random" do
    it 'has four members' do
      expect(game.length).to eq(4);
    end
  end

end
