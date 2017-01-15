require 'spec_helper'

def suitFor suit
  case suit
    when 'C'
      Bridge::Strain::Club
    when 'D'
      Bridge::Strain::Diamond
    when 'H'
      Bridge::Strain::Heart
    when 'S'
      Bridge::Strain::Spade
  end
end

def cardsFor *cards
  result = []
  cards.each do |rankAndSuit|
    rank = rankAndSuit.split(//)[0]
    suit = rankAndSuit.split(//)[1]
    result << Bridge::Card.for(suits: [suitFor(suit)], ranks: [Bridge::Rank.forLetter(rank)]).first
  end
  result
end

RSpec.describe Bridge::Pbn do

  describe ".hand" do
    let(:hand) { 'AQ942.QJ76.4.AJT' }
    let(:expectedHand) { cardsFor 'AS', 'QS', '9S', '4S', '2S',
                                  'QH', 'JH', '7H', '6H',
                                  '4D',
                                  'AC', 'JC', 'TC' }
    it 'should return the hand we expect' do
      expect(Bridge::Pbn.hand(hand)).to eq(expectedHand)
    end
  end
end
