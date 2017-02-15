require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe BetweenTags, group: :game_parser_states do
        describe('#process_char') do
          let(:subgame_builder) { double }
          let(:described_object) { make_testing_game_parser_state described_class }
          it('should raise an error for closing brace, closing bracket, or percent sign') do
            error_regexp = /.*33.*126.*closing brace.*closing bracket.*percent sign.*\].*/
            expect { described_object.process_char(']') }.to raise_error(error_regexp)
          end
        end
      end
    end
  end
end
