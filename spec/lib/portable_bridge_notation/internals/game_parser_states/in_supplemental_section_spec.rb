require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InSupplementalSection, :group => :game_parser_states do
        describe('#process_char') do
          let(:subgame_builder) { double }
          let(:described_object) { make_testing_game_parser_state described_class }
          %w(] { } ; %).each do |disallowed_symbol|
            it("should raise an error for disallowed symbol #{disallowed_symbol}. ") do
              error_regexp = Regexp.new(".*supplemental section.*.*#{Regexp.escape(disallowed_symbol)}")
              expect { described_object.process_char(disallowed_symbol) }.to raise_error(error_regexp)
            end
          end
        end
      end
    end
  end
end
