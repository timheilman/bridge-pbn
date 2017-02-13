
# intent: use code in tests that client will actually-use: standard Ruby declarations
module PortableBridgeNotation
  class TestImportObserver
    attr_reader :num_calls
    def initialize
      @num_calls = 0
    end
  end
  class TestImportListeningObserver < TestImportObserver
    def with_dealt_card(direction: direction, suit: suit, rank: rank)
      @num_calls += 1
    end
  end
  class TestImportNonlisteningObserver < TestImportObserver
    def with_unrecognized_observer_method(*args, &block)
      @num_calls += 1
    end
  end
end

require 'spec_helper'

RSpec.describe PortableBridgeNotation::Importer do
  let(:described_object) { described_class.new }
  context('with one dealt_card handler and one non-') do
    let(:dealt_card_handler) { PortableBridgeNotation::TestImportListeningObserver.new }
    let(:non_dealt_card_handler) { PortableBridgeNotation::TestImportNonlisteningObserver.new }
    let(:deal_string) { "[Deal \"N:AKQJT98765432... .AKQJT98765432.. ..AKQJT98765432. ...AKQJT98765432\"]\n\n\n" }
    it 'calls the method only on the proper observer' do
      described_object.attach(dealt_card_handler)
      described_object.attach(non_dealt_card_handler)
      described_object.import(StringIO.new(deal_string))

      expect(dealt_card_handler.num_calls).to eq 52
      expect(non_dealt_card_handler.num_calls).to eq 0
    end
  end
end
