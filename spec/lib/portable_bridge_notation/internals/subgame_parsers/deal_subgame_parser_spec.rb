require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/subgame_builder'
require_relative '../../../../../lib/portable_bridge_notation/internals/subgame_parsers/deal_subgame_parser'
module PortableBridgeNotation
  module Internals
    module SubgameParsers
      RSpec.describe DealSubgameParser do
        describe '#handle' do
          let(:domain_builder) { double }
          let(:described_object) { described_class.new(domain_builder) }
          context('when asked to handle a Deal subgame') do
            let(:subgame) do
              deal = 'N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85'
              SubgameBuilder.new.add_tag_item('Deal').add_tag_item(deal).build
            end
            before do
              allow(domain_builder).to receive :with_dealt_card
            end
            it("doesn't raise an error") do
              expect { described_object.parse subgame }.not_to raise_error
            end
            it('provides the game builder fifty-two cards') do
              expect(domain_builder).to receive(:with_dealt_card).
                  with(direction: instance_of(String), rank: instance_of(String), suit: instance_of(String)).
                  exactly(52).times
              described_object.parse subgame
            end
          end

          context('when asked to handle a non-Deal subgame') do
            let(:subgame) do
              SubgameBuilder.new.add_tag_item('NotDeal').add_tag_item('').build
            end
            it('Complains that it is not the proper handler for this type of subgame') do
              expect { described_object.parse subgame }.to raise_error(/Incorrect parser/)
            end
          end
        end
      end
    end
  end
end
