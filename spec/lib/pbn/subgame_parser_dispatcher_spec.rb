require 'spec_helper'
require_relative '../../../lib/portable_bridge_notation/internals/subgame_builder'
require_relative '../../../lib/portable_bridge_notation/internals/subgame_parser_dispatcher'

module PortableBridgeNotation
  module Internals
    RSpec.describe SubgameParserDispatcher do
      describe('#handle') do
        context('when it is called') do
          let(:domain_builder) { double }
          let(:logger) { double }
          let(:parser) { described_class.new(domain_builder, logger) }
          it('returns a subgame parser') do
            expect(parser).to respond_to :parse
          end
          context('and the result is asked to handle a nonsense tag subgame') do
            let(:subgame) do
              SubgameBuilder.new.add_tag_item('NotAValidTagName').add_tag_item('').build
            end
            it('logs a warning regarding an unrecognized tag name') do
              expect(logger).to receive(:warn).with(/.*unrecognized tag name.*/i)
              parser.parse(subgame)
            end
          end
        end
      end
    end
  end
end
