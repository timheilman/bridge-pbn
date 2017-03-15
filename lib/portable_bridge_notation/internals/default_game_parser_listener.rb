module PortableBridgeNotation
  module Internals
    class DefaultGameParserListener
      def initialize(injector)
        @injector = injector
        clear
      end

      def with_dealt_card(suit:, rank:, direction:)
        dirs = [:n, :s, :e, :w]
        @game.deal = dirs.each_with_object({}) { |dir, memo| memo[dir] = suit_for_direction; } if @game.deal.nil?
        @game.deal[direction.downcase.to_sym][suit.downcase.to_sym] << rank.upcase
      end

      def build
        return @game
      ensure
        clear
      end

      private

      def suit_for_direction
        { c: '', d: '', h: '', s: '' }
      end

      def clear
        @game = @injector.game
      end
    end
  end
end
