require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/game_parser_states/in_tag_name'
require_relative '../../../../lib/portable_bridge_notation/game_parser_states/before_tag_name'

RSpec.describe PortableBridgeNotation::GameParserStates::InTagName do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:state_factory) { double }
    let(:next_state) { double }
    let(:described_object) { described_class.new(parser, builder, state_factory) }

    %W(\t \n \v \r).each do |char|
      context("with PBN-permitted ASCII control code #{char.ord}") do
        it('should should disregard the character') do
          allow(state_factory).to receive(:make_state).with(:BeforeTagValue, ).and_return next_state
          expect(builder).to receive(:add_tag_item)
          expect(described_object.process_char(char)).to be next_state
        end
      end
    end

    context('With iso 8859/1 character è') do
      it('should complain about it as an invalid character') do
        expect {described_object.process_char('è')}.to raise_error(/.*non-name character.*è.*/)
      end
    end
  end
end
