require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InPlaySection, group: :game_parser_states do
        describe('#process_char') do
          let(:subgame_builder) { double }
          let(:described_object) { make_testing_game_parser_state described_class }
          it("raises an error because it isn't yet implemented") do
            expect { described_object.process_char ' ' }.to raise_error(/not yet implemented/)
          end
        end
      end
    end
  end
end
