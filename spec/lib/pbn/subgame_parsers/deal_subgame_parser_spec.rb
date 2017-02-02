require 'spec_helper'
RSpec.describe Bridge::Pbn::SubgameParsers::DealSubgameParser do

  describe '#handle_subgame' do
    let(:game_builder) { double }
    let(:successor) { double }
    let(:subgame_parser) { Bridge::Pbn::SubgameParsers::DealSubgameParser.new(game_builder, successor) }
    context('when asked to handle a Deal subgame') do
      let(:subgame) do
        deal = 'N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85'
        Bridge::Pbn::SubgameBuilder.new.add_tag_item('Deal').add_tag_item(deal).build
      end
      before do
        allow(game_builder).to receive(:add_hand)
      end
      it("doesn't raise an error") do
        expect { subgame_parser.handle(subgame) }.not_to raise_error
      end
      it('provides the game builder four hands') do
        expect(game_builder).to receive(:add_hand).with(instance_of(Bridge::Hand)).exactly(4).times
        subgame_parser.handle(subgame)
      end
    end
  end
end
