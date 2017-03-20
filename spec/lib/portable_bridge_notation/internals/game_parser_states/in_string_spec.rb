require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InString, group: :game_parser_states do
        describe('#process_char') do
          let(:described_object) { make_testing_game_parser_state described_class }
          %W(\t \n \v \r).each do |char|
            context("with PBN-permitted ASCII control code #{char.ord}") do
              it('should raise an error since it is within a string') do
                error_regexp = Regexp.new ".*ASCII control.*: #{char.ord}"
                expect { described_object.process_char(char) }.to raise_error(error_regexp)
              end
            end
          end
        end
      end
    end
  end
end
