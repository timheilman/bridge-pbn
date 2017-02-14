require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_factory'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe BeforeFirstTag do
        describe('#process_char') do
          let(:game_parser) { double }
          let(:subgame_builder) { double }
          let(:described_object) { GameParserStateFactory.new(
              game_parser: game_parser, subgame_builder: subgame_builder).make_game_parser_state(:BeforeFirstTag) }
          it('should skip whitespace') do
            expect(described_object.process_char("\t")).to be(described_object)
          end

          it('should raise an error for any non-whitespace, non-comment, and non-open-bracket char') do
            error = StandardError.new 'Mock error'
            error_regexp = /.*section element starting.*\^.*/
            expect(game_parser).to receive(:raise_error).with(match error_regexp).and_raise error
            expect { described_object.process_char('^') }.to raise_error StandardError
          end
        end
      end
    end
  end
end

