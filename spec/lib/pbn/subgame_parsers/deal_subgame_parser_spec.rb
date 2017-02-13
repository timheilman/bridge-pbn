require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/subgame_builder'
require_relative '../../../../lib/portable_bridge_notation/subgame_parsers/deal_subgame_parser'
RSpec.describe PortableBridgeNotation::SubgameParsers::DealSubgameParser do

  describe '#handle_subgame' do
    let(:game_builder) { double }
    let(:successor) { double }
    let(:described_object) { described_class.new(game_builder, successor) }
    context('when asked to handle a Deal subgame') do
      let(:subgame) do
        deal = 'N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85'
        PortableBridgeNotation::SubgameBuilder.new.add_tag_item('Deal').add_tag_item(deal).build
      end
      before do
        allow(game_builder).to receive :with_dealt_card
      end
      it("doesn't raise an error") do
        expect { described_object.handle subgame }.not_to raise_error
      end
      it('provides the game builder fifty-two cards') do
        expect(game_builder).to receive(:with_dealt_card).
            with(direction: instance_of(String), rank: instance_of(String), suit: instance_of(String)).
            exactly(52).times
        described_object.handle subgame
      end
    end

    context('when asked to handle a non-Deal subgame') do
      let(:subgame) do
        PortableBridgeNotation::SubgameBuilder.new.add_tag_item('NotDeal').add_tag_item('').build
      end
      before do
        allow(successor).to receive(:handle) { :successors_return }
      end
      it('Defers to the successor and returns its result') do
        expect(described_object.handle subgame).to be (:successors_return)
      end
    end
  end
end
