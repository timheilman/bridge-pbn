require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/game_parser_states/before_tag_close'

RSpec.describe PortableBridgeNotation::GameParserStates::BeforeTagClose do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:state_factory) { double }
    let(:described_object) { described_class.new(parser, builder, state_factory) }

    it('should skip whitespace') do
      expect(described_object.process_char("\t")).to be(described_object)
    end

    it('should raise an error for any non-whitespace and non-] char') do
      expect(parser).to receive(:raise_error).with(match '.*whitespace.*closing bracket.*;')
      described_object.process_char(';')
    end
  end

end
