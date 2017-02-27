require_relative '../../../lib/portable_bridge_notation/importer'
require 'spec_helper'
module PortableBridgeNotation
  # intent: use code in tests that client will actually-use: standard Ruby declarations
  class TestImportObserver
    attr_reader :num_calls

    def initialize
      @num_calls = 0
    end
  end
  class TestImportListeningObserver < TestImportObserver
    def with_dealt_card(direction:, suit:, rank:)
      [direction, suit, rank].map { |arg| raise StandardError if arg.nil? }
      @num_calls += 1
    end
  end
  class TestImportNonlisteningObserver < TestImportObserver
    def with_unrecognized_observer_method(*_args)
      @num_calls += 1
    end
  end
  RSpec.describe Importer do
    let(:described_object) { described_class.new }
    let(:io) { StringIO.new("[Deal \"N:AKQJT98765432... .AKQJT98765432.. ..AKQJT98765432. ...AKQJT98765432\"]\n") }
    context('with one dealt_card observer') do
      let(:dealt_card_observer) { TestImportListeningObserver.new }
      context('and one non-dealt_card observer') do
        let(:non_dealt_card_observer) { TestImportNonlisteningObserver.new }
        # TODO: test edge case with multiple \n's
        # TODO: see section 4.8; TDD handling of # and ## tag values
        it 'calls the sole declared method only on the proper observer' do
          described_object.attach_observer(dealt_card_observer)
          described_object.attach_observer(non_dealt_card_observer)
          described_object.import(io)

          expect(dealt_card_observer.num_calls).to eq 52
          expect(non_dealt_card_observer.num_calls).to eq 0
        end
      end
      context('and an additional dealt_card observer') do
        let(:additional_dealt_card_observer) { TestImportListeningObserver.new }
        it 'calls the declared method on both the listening observers' do
          described_object.attach_observer(dealt_card_observer)
          described_object.attach_observer(additional_dealt_card_observer)
          described_object.import(io)

          expect(dealt_card_observer.num_calls).to eq 52
          expect(additional_dealt_card_observer.num_calls).to eq 52
        end
      end
    end
  end
end
