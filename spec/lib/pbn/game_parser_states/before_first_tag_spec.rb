require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/game_parser_states/before_first_tag'
RSpec.describe PortableBridgeNotation::GameParserStates::BeforeFirstTag do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:state_factory) { double }
    let(:described_object) { described_class.new(parser, builder, state_factory) }
    it('should skip whitespace') do
      expect(described_object.process_char("\t")).to be(described_object)
    end

    it('should raise an error for any non-whitespace, non-comment, and non-open-bracket char') do
      error = StandardError.new 'Mock error'
      error_regexp = /.*section element starting.*\^.*/
      expect(parser).to receive(:raise_error).with(match error_regexp).and_raise error
      expect { described_object.process_char('^') }.to raise_error StandardError
    end
  end

end
