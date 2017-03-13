module PortableBridgeNotation
  module Internals
    class TestImportObserver
      attr_reader :num_calls
      def initialize
        @num_calls = 0
      end
    end
    class TestImportListeningObserver < TestImportObserver
      def method_to_be_broadcast(*_args)
        @num_calls += 1
      end
    end
    class TestImportNonlisteningObserver < TestImportObserver
      def with_unrecognized_observer_method(*_args)
        @num_calls += 1
      end
    end

    RSpec.describe ObserverBroadcaster do
      let(:described_object) { described_class.new }
      context('with one observer') do
        let(:dealt_card_observer) { TestImportListeningObserver.new }
        context('and one non-dealt_card observer') do
          let(:non_dealt_card_observer) { TestImportNonlisteningObserver.new }
          # TODO: test edge case with multiple \n's
          # TODO: see section 4.8; TDD handling of # and ## tag values
          it 'calls the sole declared method only on the proper observer' do
            described_object.add_observer(dealt_card_observer)
            described_object.add_observer(non_dealt_card_observer)
            described_object.method_to_be_broadcast('some', :arguments)
            expect(dealt_card_observer.num_calls).to eq 1
            expect(non_dealt_card_observer.num_calls).to eq 0
          end
        end
        context('and an additional dealt_card observer') do
          let(:additional_dealt_card_observer) { TestImportListeningObserver.new }
          it 'calls the declared method on both the listening observers' do
            described_object.add_observer(dealt_card_observer)
            described_object.add_observer(additional_dealt_card_observer)
            described_object.method_to_be_broadcast('other', :arguments)
            expect(dealt_card_observer.num_calls).to eq 1
            expect(additional_dealt_card_observer.num_calls).to eq 1
          end
        end
      end
    end
  end
end
