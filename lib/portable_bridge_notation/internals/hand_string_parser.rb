require_relative 'single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    class HandStringParser
      include SingleCharComparisonConstants

      def initialize(hand_string)
        @hand_string = hand_string
      end

      def yield_cards(&block)
        hand_string.split(period).each_with_index do |ranks_string, suit_index|
          @ranks_string = ranks_string
          @suit_index = suit_index
          yield_cards_for_suit &block
        end
      end

      private

      attr_reader :hand_string
      attr_reader :ranks_string
      attr_reader :suit_index

      def yield_cards_for_suit
        ranks_string.split(//).each do |rank_char|
          yield suit: suit_char_for(suit_index), rank: rank_char
        end
      end

      def suit_char_for(index)
        {0 => 'S', 1 => 'H', 2 => 'D', 3 => 'C'}[index]
      end

    end
  end
end
