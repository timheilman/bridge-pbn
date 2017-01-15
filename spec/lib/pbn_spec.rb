require 'spec_helper'

def suit_for(suit)
  case suit
    when 'C'
      Bridge::Strain::Club
    when 'D'
      Bridge::Strain::Diamond
    when 'H'
      Bridge::Strain::Heart
    when 'S'
      Bridge::Strain::Spade
    else
      raise ArgumentError.new 'Got unidentifiable suit letter: `' + suit + "'"
  end
end

def cards_for(*cards)
  result = []
  cards.each do |rankAndSuit|
    rank = rankAndSuit.split(//)[0]
    suit = rankAndSuit.split(//)[1]
    result << Bridge::Card.for(suits: [suit_for(suit)], ranks: [Bridge::Rank.forLetter(rank)]).first
  end
  result
end

RSpec.describe Bridge::Pbn do

  describe '.hand' do
    let(:hand) { 'AQ942.QJ76.4.AJT' }
    let(:expectedHand) { cards_for 'AS', 'QS', '9S', '4S', '2S',
                                   'QH', 'JH', '7H', '6H',
                                   '4D',
                                   'AC', 'JC', 'TC' }
    it 'should return the hand we expect' do
      expect(Bridge::Pbn.hand(hand)).to eq(expectedHand)
    end
  end
end
