require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/game_parser_states/between_tags'

RSpec.describe PortableBridgeNotation::GameParserStates::BetweenTags do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:state_factory) { double }
    let(:next_state) { double }
    let(:described_object) { described_class.new(parser, builder, state_factory) }
    let(:error) { StandardError.new 'Mock error' }

    it('should raise an error for closing brace, closing bracket, or percent sign') do
      error_regexp = /.*33.*126.*closing brace.*closing bracket.*percent sign.*\].*/
      expect(parser).to receive(:raise_error).with(error_regexp).and_raise error
      expect { described_object.process_char(']') }.to raise_error StandardError
    end

  end

end
