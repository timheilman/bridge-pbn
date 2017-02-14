require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_factory'

module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe BetweenTags do
        describe('#process_char') do
          let(:game_parser) { double }
          let(:subgame_builder) { double }
          let(:described_object) { GameParserStateFactory.new(
              game_parser, subgame_builder).make_state(:BetweenTags) }
          let(:error) { StandardError.new 'Mock error' }

          it('should raise an error for closing brace, closing bracket, or percent sign') do
            error_regexp = /.*33.*126.*closing brace.*closing bracket.*percent sign.*\].*/
            expect(game_parser).to receive(:raise_error).with(error_regexp).and_raise error
            expect { described_object.process_char(']') }.to raise_error StandardError
          end
        end
      end
    end
  end
end
