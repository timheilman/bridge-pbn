require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/game_parser_states/game_parser_state_factory'

RSpec.describe PortableBridgeNotation::GameParserStates::BeforeTagValue do
  describe('#process_char') do
    let(:game_parser) { double }
    let(:domain_builder) { double }
    let(:described_object) { PortableBridgeNotation::GameParserStates::GameParserStateFactory.new(
        game_parser, domain_builder).make_state(:BeforeTagValue) }
    it('should skip whitespace') do
      expect(described_object.process_char("\v")).to be(described_object)
    end

    it('should raise an error for any non-whitespace and non-double-quote token string') do
      expect(game_parser).to receive(:raise_error).with(match '.*whitespace.*double quote.*;')
      described_object.process_char(';')
    end

  end
end
