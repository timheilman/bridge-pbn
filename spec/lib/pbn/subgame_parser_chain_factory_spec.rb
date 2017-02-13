require 'spec_helper'
require_relative '../../../lib/portable_bridge_notation/subgame_builder'
require_relative '../../../lib/portable_bridge_notation/subgame_parser_chain_factory'

RSpec.describe PortableBridgeNotation::SubgameParserChainFactory do
  describe('#get_chain') do
    context('when it is called') do
      let(:game_builder) { double }
      let(:logger) { double }
      let(:chain) { described_class.new(game_builder, logger).get_chain }
      it('returns a handler') do
        expect(chain).to respond_to :handle
      end
      context('and the result is asked to handle a nonsense tag subgame') do
        let(:subgame) do
          PortableBridgeNotation::SubgameBuilder.new.add_tag_item('NotAValidTagName').add_tag_item('').build
        end
        it('logs a warning regarding an unrecognized tag name') do
          expect(logger).to receive(:warn).with(/.*unrecognized tag name.*/i)
          chain.handle(subgame)
        end

      end
    end
  end
end
