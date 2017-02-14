require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_factory'

module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe BeforeTagClose do
        describe('#process_char') do
          let(:game_parser) { double }
          let(:subgame_builder) { double }
          let(:described_object) { GameParserStateFactory.new(
              game_parser: game_parser, subgame_builder: subgame_builder).make_game_parser_state(:BeforeTagClose) }

          it('should skip whitespace') do
            expect(described_object.process_char("\t")).to be(described_object)
          end

          it('should raise an error for any non-whitespace and non-] char') do
            expect(game_parser).to receive(:raise_error).with(match '.*whitespace.*closing bracket.*;')
            described_object.process_char(';')
          end
        end
      end
    end
  end
end
