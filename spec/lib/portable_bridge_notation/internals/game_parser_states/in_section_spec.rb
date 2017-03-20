require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InUnrecognizedSupplementalSection, group: :game_parser_states do
        describe('#process_char') do
          let(:described_object) { make_testing_game_parser_state described_class }
          %w(] } %).each do |disallowed_symbol|
            it("should raise an error for disallowed symbol #{disallowed_symbol}. ") do
              error_regexp = Regexp.new(".*supplemental section.*.*#{Regexp.escape(disallowed_symbol)}")
              expect { described_object.process_char(disallowed_symbol) }.to raise_error(error_regexp)
            end
          end
          it('should not raise an error for disallowed symbol ; before noncommentary consumed') do
            expect(described_object.process_char(';')).to be_an_instance_of InSemicolonComment
          end
          it('should not raise an error for disallowed symbol { before noncommentary consumed') do
            expect(described_object.process_char('{')).to be_an_instance_of InCurlyComment
          end
          %w({ ;).each do |disallowed_symbol|
            it("should raise an error for disallowed symbol #{disallowed_symbol} after noncommentary consumed") do
              described_object.process_char('a')
              error_regexp = Regexp.new(".*supplemental section.*.*#{Regexp.escape(disallowed_symbol)}")
              expect { described_object.process_char(disallowed_symbol) }.to raise_error(error_regexp)
            end
          end
        end
      end
    end
  end
end
