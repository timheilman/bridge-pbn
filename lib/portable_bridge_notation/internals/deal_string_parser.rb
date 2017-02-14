require_relative 'hand_string_parser'
require_relative 'single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    class DealStringParser
      include SingleCharComparisonConstants

      def initialize(deal_string)
        @deal_string = deal_string
      end

      def yield_cards(&block)
        @hand_0_direction, @hand_strings = deal_string.split(colon)
        yield_hands block
      end

      private

      attr_reader :deal_string
      attr_reader :hand_0_direction
      attr_reader :hand_strings
      attr_reader :hand_string
      attr_reader :hand_index

      def yield_hands(block)
        hand_strings.split(space).each_with_index do |hand_string, hand_index|
          next if hand_string == hyphen
          @hand_string = hand_string
          @hand_index = hand_index
          yield_hand &block
        end
      end

      def yield_hand
        HandStringParser.new(hand_string).yield_cards do |suit: suit, rank: rank|
          yield direction: direction_char, suit: suit, rank: rank
        end
      end

      def direction_char
        directions = %w(N E S W)
        index_of_hand_0_direction = directions.find_index(hand_0_direction)
        raise_error hand_0_direction if index_of_hand_0_direction.nil?
        directions[(index_of_hand_0_direction + hand_index) % directions.size]
      end

      def raise_error initial_dir
        raise ArgumentError.new("bad first position character for pgn deal string: `#{initial_dir}'")
      end

    end
  end
end
