require 'active_support/inflector'
module PortableBridgeNotation
  module Internals
    class DefaultGameParserListener
      def initialize(injector)
        @injector = injector
        clear
      end

      def with_dealt_card(suit:, rank:, direction:)
        dir_sym = direction.downcase.to_sym
        suit_sym = suit.downcase.to_sym
        init_game_deal_for_dir dir_sym
        game.deal[dir_sym][suit_sym] << rank.upcase
      end

      def init_game_deal_for_dir(dir_sym)
        game.deal = {} if game.deal.nil?
        game.deal[dir_sym] = { c: '', d: '', h: '', s: '' } unless game.deal.include? dir_sym
      end

      def with_unrecognized_supplemental_section(tag_name:, tag_value:, section:, comments:)
        game.supplemental_sections[tag_name.to_sym] = Api::SupplementalSection.new(tag_value, section, comments)
      end

      def build
        return game
      ensure
        clear
      end

      private

      attr_reader :injector
      attr_accessor :game

      def suit_for_direction
        { c: '', d: '', h: '', s: '' }
      end

      def clear
        self.game = injector.game
      end

      def method_missing(method_sym, *arguments, &block)
        method_s = method_sym.to_s
        return super unless method_s =~ /^with_/
        simple_string_field = method_s.match(/^with_(.*)$/)[1]
        game.send((simple_string_field << '=').to_sym, *arguments)
      end

      def respond_to_missing?(method_sym, include_private = false)
        method_s = method_sym.to_s
        return super unless method_s =~ /^with_/
        simple_string_field = method_s.match(/^with_(.*)$/)[1]
        game.respond_to? simple_string_field.to_sym
      end
    end
  end
end
