require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/injector'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InNoteSection, group: :game_parser_states do
        describe '#finalize' do
          context('when asked to parse an ordinary note') do
            let(:game_parser) { double }
            let(:described_object) do
              described_object = described_class.new(injector: Injector.new,
                                                     observer: nil,
                                                     game_parser: game_parser,
                                                     enclosing_state: nil)
              described_object.tag_value = note
              described_object
            end
            let(:note) { '2:two colors: clubs and diamonds' }
            before { allow(game_parser).to receive :add_note_ref_resolution }
            it("doesn't raise an error") do
              expect { described_object.finalize }.not_to raise_error
            end
            it('notifies the game_parser of the note ref values') do
              expect(game_parser).to receive(:add_note_ref_resolution)
                .with(2, 'two colors: clubs and diamonds')
                .exactly(1).times
              described_object.finalize
            end
          end
        end
      end
    end
  end
end
