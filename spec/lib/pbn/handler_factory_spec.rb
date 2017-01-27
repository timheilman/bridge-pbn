require 'spec_helper'

RSpec.describe Bridge::Pbn::SubgameParserChainFactory do
  describe('#get_chain') do
    context('when it is called') do
      let(:game_builder) { double }
      let(:logger) { double }
      let(:chain) { described_class.new(game_builder, logger).get_chain }
      it('returns a handler') do
        expect(chain).to respond_to :handle
        expect(chain).to respond_to :defer
      end
      context('and the result is asked to handle a nonsense tag subgame') do
        let(:subgame) do
          Bridge::Pbn::SubgameBuilder.new.add_tag_item('NotAValidTagName').add_tag_item('').build
        end
        it('logs a warning regarding an unrecognized tag name') do
          expect(logger).to receive(:warn).with(/.*unrecognized tag name.*/i)
          chain.handle(subgame)
        end

      end
      context('and the result is asked to handle a Deal subgame') do
        let(:subgame) do
          deal = 'N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85'
          Bridge::Pbn::SubgameBuilder.new.add_tag_item('Deal').add_tag_item(deal).build
        end
        before do
          allow(game_builder).to receive(:add_hand)
        end
        it("doesn't raise an error") do
          expect { chain.handle(subgame) }.not_to raise_error
        end
        it('provides the game builder four hands') do
          expect(game_builder).to receive(:add_hand).with(instance_of(Bridge::Hand)).exactly(4).times
          chain.handle(subgame)
        end
      end
    end
  end
end
