require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe BeforeFirstTag, group: :game_parser_states do
        describe('#process_char') do
          let(:subgame_builder) { double }
          let(:described_object) { make_testing_game_parser_state described_class }
          it('should skip whitespace') do
            expect(described_object.process_char("\t")).to be(described_object)
          end

          it('should raise an error for any non-whitespace, non-comment, and non-open-bracket char') do
            expect { described_object.process_char('^') }.to raise_error(/.*section element starting.*\^.*/)
          end
        end
      end
    end
  end
end
