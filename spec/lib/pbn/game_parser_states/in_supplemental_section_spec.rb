require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_factory'

module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InSupplementalSection do
        describe('#process_char') do
          let(:game_parser) { double }
          let(:subgame_builder) { double }
          let(:described_object) { GameParserStateFactory.new(
              game_parser, subgame_builder).make_state(:InSupplementalSection) }
          %w(] { } ; %).each do |disallowed_symbol|
            it("should raise an error for disallowed symbol #{disallowed_symbol}. ") do
              error = StandardError.new 'Mock error'
              error_regexp = Regexp.new(".*supplemental section.*.*#{Regexp.escape(disallowed_symbol)}")
              expect(game_parser).to receive(:raise_error).with(match error_regexp).and_raise error
              expect { described_object.process_char(disallowed_symbol) }.to raise_error StandardError
            end
          end
        end
      end
    end
  end
end
