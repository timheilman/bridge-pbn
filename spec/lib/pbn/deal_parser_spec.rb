require 'spec_helper'

def cards_for(*cards)
  result = []
  cards.each do |rankAndSuit|
    rank, suit = rankAndSuit.split(//)
    result << Bridge::Card.for(suits: [Bridge::Strain.for_string(suit)], ranks: [Bridge::Rank.for_char(rank)]).first
  end
  result
end

def let_expected_hands
  let(:expectedNHand) {
    cards_for('6H', '3H',
              'AD', 'KD', 'QD', '9D', '8D', '7D',
              'AC', '9C', '7C', '3C', '2C') }
  let(:expectedEHand) {
    cards_for('AS', '8S', '6S', '5S', '4S',
              'KH', 'QH', '5H',
              'TD',
              'QC', 'JC', 'TC', '6C') }
  let(:expectedSHand) {
    cards_for('JS', '9S', '7S', '3S',
              'JH', '9H', '8H', '7H', '4H', '2H',
              '3D',
              'KC', '4C') }
  let(:expectedWHand) {
    cards_for('KS', 'QS', 'TS', '2S',
              'AH', 'TH',
              'JD', '6D', '5D', '4D', '2D',
              '8C', '5C') }
end

RSpec.describe Bridge::Pbn::DealParser do

  describe '.hand' do
    let_expected_hands
    let(:hand) { '.63.AKQ987.A9732' }
    it 'returns the hand we expect' do
      expect(described_class.hand(hand)).to eq(expectedNHand)
    end
  end

  describe '.deal' do
    let_expected_hands
    context 'with N first' do
      let(:deal) { 'N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }

      it 'returns the game we expect' do
        expect(described_class.deal deal).to eq([expectedNHand, expectedEHand, expectedSHand, expectedWHand])
      end
    end
    context 'with E first' do
      let(:deal) { 'E:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }
      it 'returns the same game with the hands rotated clockwise once' do
        expect(described_class.deal deal).to eq([expectedEHand, expectedSHand, expectedWHand, expectedNHand])
      end
    end
    context 'with S first' do
      let(:deal) { 'S:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }
      it 'returns the same game with the hands rotated clockwise twice' do
        expect(described_class.deal deal).to eq([expectedSHand, expectedWHand, expectedNHand, expectedEHand])
      end
    end
    context 'with W first' do
      let(:deal) { 'W:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }
      it 'returns the same game with the hands rotated counterclockwise once' do
        expect(described_class.deal deal).to eq([expectedWHand, expectedNHand, expectedEHand, expectedSHand])
      end
    end
    context 'with hyphens for some hands' do
      let(:deal) { 'N:- A8654.KQ5.T.QJT6 - KQT2.AT.J6542.85' }
      it 'returns nils for hands not specified' do
        expect(described_class.deal deal).to eq([nil, expectedEHand, nil, expectedWHand])
      end
    end
    context 'with a bad direction letter' do
      let(:deal) { 'M:foo' }
      it 'raises an error' do
        expect { described_class.deal deal }.to raise_error(/.*first position.*M.*/)
      end
    end
  end
end
