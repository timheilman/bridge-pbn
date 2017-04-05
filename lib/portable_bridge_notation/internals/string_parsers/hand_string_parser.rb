require_relative '../single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    class HandStringParser
      include SingleCharComparisonConstants

      def initialize(hand_string)
        @hand_string = hand_string
      end

      def yield_cards(&block)
        self.block = block
        hand_string.split(period).each_with_index do |ranks_string, suit_index|
          self.ranks_string = ranks_string
          self.suit_index = suit_index
          yield_cards_for_suit
        end
      end

      private

      attr_reader :hand_string
      attr_accessor :ranks_string
      attr_accessor :suit_index
      attr_accessor :block

      def yield_cards_for_suit
        ranks_string.split(//).each do |rank_char|
          block.yield suit: suit_char_for(suit_index), rank: rank_char
        end
      end

      def suit_char_for(index)
        { 0 => 'S', 1 => 'H', 2 => 'D', 3 => 'C' }[index]
      end
    end
  end
end
