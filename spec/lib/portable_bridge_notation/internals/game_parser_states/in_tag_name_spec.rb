require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_factory'

module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InTagName do
        describe('#process_char') do
          let(:game_parser) { double }
          let(:subgame_builder) { double }
          let(:factory) { GameParserStateFactory.new(game_parser: game_parser, subgame_builder: subgame_builder) }
          let(:described_object) { factory.make_game_parser_state(:InTagName) }

          %W(\t \n \v \r).each do |char|
            context("with PBN-permitted ASCII control code #{char.ord}") do
              it('should should disregard the character') do
                expect(subgame_builder).to receive(:add_tag_item)
                expect(described_object.process_char(char)).to be_a BeforeTagValue
              end
            end
          end

          context('With iso 8859/1 character è') do
            it('should complain about it as an invalid character') do
              expect { described_object.process_char('è') }.to raise_error(/.*non-name character.*è.*/)
            end
          end
        end
      end
    end
  end
end

