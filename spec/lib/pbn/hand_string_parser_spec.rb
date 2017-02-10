require 'spec_helper'

RSpec.describe Bridge::Pbn::HandStringParser do
  describe '.hand' do
    let(:described_object) { Bridge::Pbn::HandStringParser.new(hand) }
    context 'provided a valid PBN hand string' do
      let(:hand) { '.63.AKQ987.A9732' }
      it 'yields the proper suits and ranks' do
        expect { |block| described_object.yield_cards(&block) }.to yield_successive_args(
                                                                      {suit: 'H', rank: '6'},
                                                                      {suit: 'H', rank: '3'},
                                                                      {suit: 'D', rank: 'A'},
                                                                      {suit: 'D', rank: 'K'},
                                                                      {suit: 'D', rank: 'Q'},
                                                                      {suit: 'D', rank: '9'},
                                                                      {suit: 'D', rank: '8'},
                                                                      {suit: 'D', rank: '7'},
                                                                      {suit: 'C', rank: 'A'},
                                                                      {suit: 'C', rank: '9'},
                                                                      {suit: 'C', rank: '7'},
                                                                      {suit: 'C', rank: '3'},
                                                                      {suit: 'C', rank: '2'},
                                                                  )
      end
    end
  end

end

