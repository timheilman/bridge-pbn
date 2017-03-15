require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/injector'
require_relative '../../../../../lib/portable_bridge_notation/internals/subgame_parsers/note_subgame_parser'
module PortableBridgeNotation
  module Internals
    module SubgameParsers
      RSpec.describe NoteSubgameParser do
        describe '#parse' do
          let(:game_parser) { double }
          let(:described_object) do
            described_class.new(injector: Injector.new,
                                observer: nil,
                                game_parser: game_parser)
          end
          context('when asked to parse an ordinary note') do
            before do
              allow(game_parser).to receive :add_note_ref_resolution
            end
            let(:subgame) do
              note = '2:two colors: clubs and diamonds'
              SubgameBuilder.new.add_tag_item('Note').add_tag_item(note).build
            end
            it("doesn't raise an error") do
              expect { described_object.parse subgame }.not_to raise_error
            end
            it('notifies the game_parser of the note ref values') do
              expect(game_parser).to receive(:add_note_ref_resolution)
                .with(2, 'two colors: clubs and diamonds')
                .exactly(1).times
              described_object.parse subgame
            end
          end
        end
      end
    end
  end
end
