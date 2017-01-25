require 'spec_helper'


RSpec.describe Bridge::Card do
  subject(:card) { Bridge::Card.new }
  describe '.all' do
    it 'returns 52 cards' do
      expect(Bridge::Card.all.length).to eq(52)
    end
  end
end
