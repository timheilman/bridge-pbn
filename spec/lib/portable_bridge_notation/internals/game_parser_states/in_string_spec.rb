require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_factory'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InString do
        describe('#process_char') do
          let(:game_parser) { double }
          let(:subgame_builder) { double }
          let(:described_object) { GameParserStateFactory.new(
              game_parser: game_parser, subgame_builder: subgame_builder).make_game_parser_state(:InString) }

          %W(\t \n \v \r).each do |char|
            context("with PBN-permitted ASCII control code #{char.ord}") do
              it('should raise an error since it is within a string') do
                expect(game_parser).to receive(:raise_error).with(match ".*ASCII control.*: #{char.ord}")
                described_object.process_char(char)
              end
            end
          end
        end
      end
    end
  end
end
