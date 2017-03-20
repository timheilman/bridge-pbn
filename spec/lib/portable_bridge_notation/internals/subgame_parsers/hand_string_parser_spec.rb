require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/string_parsers/hand_string_parser'
module PortableBridgeNotation
  module Internals
    RSpec.describe HandStringParser do
      describe '.hand' do
        let(:described_object) { HandStringParser.new(hand) }
        context 'provided a valid PBN hand string' do
          let(:hand) { '7.63.AKQJT.A9732' }
          it 'yields the proper suits and ranks' do
            expect { |block| described_object.yield_cards(&block) }.to yield_successive_args(
              { suit: 'S', rank: '7' },
              { suit: 'H', rank: '6' },
              { suit: 'H', rank: '3' },
              { suit: 'D', rank: 'A' },
              { suit: 'D', rank: 'K' },
              { suit: 'D', rank: 'Q' },
              { suit: 'D', rank: 'J' },
              { suit: 'D', rank: 'T' },
              { suit: 'C', rank: 'A' },
              { suit: 'C', rank: '9' },
              { suit: 'C', rank: '7' },
              { suit: 'C', rank: '3' },
              suit: 'C', rank: '2'
            )
          end
        end
      end
    end
  end
end
