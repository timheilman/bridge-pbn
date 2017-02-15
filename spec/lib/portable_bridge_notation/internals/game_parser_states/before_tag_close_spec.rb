require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe BeforeTagClose, group: :game_parser_states do
        describe('#process_char') do
          let(:subgame_builder) { double }
          let(:described_object) { make_testing_game_parser_state described_class }
          it('should skip whitespace') do
            expect(described_object.process_char("\t")).to be(described_object)
          end

          it('should raise an error for any non-whitespace and non-] char') do
            expect { described_object.process_char(';') }.to raise_error(/.*whitespace.*closing bracket.*;/)
          end
        end
      end
    end
  end
end
