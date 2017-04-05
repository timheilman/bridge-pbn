require_relative '../single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    class DealStringParser
      include SingleCharComparisonConstants

      def initialize(injector, deal_string)
        @injector = injector
        @hand_0_direction, @hand_strings = deal_string.split(colon)
      end

      def yield_cards(&block)
        return enum_for(:yield_cards) unless block_given?
        self.block = block
        yield_hands
      end

      private

      attr_reader :injector
      attr_reader :hand_0_direction
      attr_reader :hand_strings
      attr_accessor :block
      attr_accessor :hand_string
      attr_accessor :hand_index

      def yield_hands
        hand_strings.split(space).each_with_index do |hand_string, hand_index|
          next if hand_string == hyphen
          self.hand_string = hand_string
          self.hand_index = hand_index
          yield_hand
        end
      end

      def yield_hand
        injector.hand_string_parser(hand_string).yield_cards do |suit:, rank:|
          block.yield direction: direction_char, suit: suit, rank: rank
        end
      end

      def direction_char
        directions = %w(N E S W)
        index_of_hand_0_direction = directions.find_index(hand_0_direction)
        raise_error hand_0_direction if index_of_hand_0_direction.nil?
        directions[(index_of_hand_0_direction + hand_index) % directions.size]
      end

      def raise_error(initial_dir)
        raise injector.error("bad first position character for pgn deal string: `#{initial_dir}'")
      end
    end
  end
end
