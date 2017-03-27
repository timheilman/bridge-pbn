module PortableBridgeNotation
  module ReferenceImplementationTests
    module RefImplTestHelper
      def import_only_game
        game_enumerator = described_object.import
        game = game_enumerator.next
        expect { game_enumerator.next }.to raise_error(StopIteration)
        game
      end
    end
  end
end
