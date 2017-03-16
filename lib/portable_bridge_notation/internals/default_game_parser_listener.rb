require 'active_support/inflector'
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

      def method_missing(method_sym, *arguments, &block)
        method_s = method_sym.to_s
        return super unless method_s =~ /^with_/
        simple_string_field = method_s.match(/^with_(.*)$/)[1]
        @game.send((simple_string_field << '=').to_sym, *arguments)
      end

      def respond_to_missing?(method_sym, include_private = false)
        method_s = method_sym.to_s
        return super unless method_s =~ /^with_/
        simple_string_field = method_s.match(/^with_(.*)$/)[1]
        @game.respond_to? simple_string_field.to_sym
      end
    end
  end
end
