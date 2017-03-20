require 'spec_helper'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InTagName, group: :game_parser_states do
        describe('#process_char') do
          let(:described_object) { make_testing_game_parser_state described_class }
          %W(\t \n \v \r).each do |char|
            context("with PBN-permitted ASCII control code #{char.ord}") do
              it('should disregard the character') do
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
