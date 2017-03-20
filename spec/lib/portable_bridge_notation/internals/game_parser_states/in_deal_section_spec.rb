require 'spec_helper'
require_relative '../../../../../lib/portable_bridge_notation/internals/injector'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      RSpec.describe InDealSection, group: :game_parser_states do
        describe('#finalize') do
          let(:described_object) do
            described_object = make_testing_game_parser_state described_class, observer: observer
            described_object.tag_value = 'N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85'
            described_object
          end
          let(:observer) { double }
          let(:logger) { nil }
          let(:pbn_game_string) { nil }
          before do
            allow(observer).to receive :with_dealt_card
          end
          it("doesn't raise an error") do
            expect { described_object.finalize }.not_to raise_error
          end
          it('provides the observer fifty-two cards') do
            expect(observer).to receive(:with_dealt_card)
              .with(direction: instance_of(String), rank: instance_of(String), suit: instance_of(String))
              .exactly(52).times
            described_object.finalize
          end
        end
      end
    end
  end
end
