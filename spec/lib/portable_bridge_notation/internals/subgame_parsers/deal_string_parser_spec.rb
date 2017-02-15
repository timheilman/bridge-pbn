require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/subgame_parsers/deal_string_parser'
require_relative '../../../../../lib/portable_bridge_notation/internals/concrete_factory'

module PortableBridgeNotation
  module Internals
    RSpec.describe DealStringParser do
      describe '.yield_cards' do
        let(:described_object) { ConcreteFactory.new.make_deal_string_parser(deal) }
        context 'provided a PBN deal string with only the aces dealt' do
          let(:space_separated_hands) { '..A.A A... ... .A..' }
          context 'starting with N' do
            let(:deal) { 'N:' + space_separated_hands }
            it 'yields with aces in proper places, two in the north' do
              expect { |block| described_object.yield_cards(&block) }.to yield_successive_args(
                { direction: 'N', suit: 'D', rank: 'A' },
                { direction: 'N', suit: 'C', rank: 'A' },
                { direction: 'E', suit: 'S', rank: 'A' },
                direction: 'W', suit: 'H', rank: 'A'
              )
            end
          end
          context 'starting with E' do
            let(:deal) { 'E:' + space_separated_hands }
            it 'yields with aces in proper places, two in the east' do
              expect { |block| described_object.yield_cards(&block) }.to yield_successive_args(
                { direction: 'E', suit: 'D', rank: 'A' },
                { direction: 'E', suit: 'C', rank: 'A' },
                { direction: 'S', suit: 'S', rank: 'A' },
                direction: 'N', suit: 'H', rank: 'A'
              )
            end
          end
        end

        context 'with hyphens for some hands' do
          let (:deal) { 'E:..A.A - ... -' }
          it 'deals the non-hyphen cards' do
            expect { |block| described_object.yield_cards(&block) }.to yield_successive_args(
              { direction: 'E', suit: 'D', rank: 'A' },
              direction: 'E', suit: 'C', rank: 'A'
            )
          end
        end

        context 'with a bad initial direction letter' do
          let (:deal) { 'M:foo' }
          it 'raises an error' do
            expect { |block| described_object.yield_cards(&block) }.to raise_error /.*first position.*M.*/
          end
        end
      end
    end
  end
end
