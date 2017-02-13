require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/game_parser_states/game_parser_state_factory'
RSpec.describe PortableBridgeNotation::GameParserStates::BeforeFirstTag do
  describe('#process_char') do
    let(:game_parser) { double }
    let(:subgame_builder) { double }
    let(:described_object) { PortableBridgeNotation::GameParserStates::GameParserStateFactory.new(
        game_parser, subgame_builder).make_state(:BeforeFirstTag) }
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
