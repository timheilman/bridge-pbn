require_relative 'io_parser'
require_relative 'subgame_builder'
require_relative 'game_parser'
require_relative 'portable_bridge_notation_error'

# all defined states should be required here
require_relative 'game_parser_states/game_parser_state'
require_relative 'game_parser_states/outside_tag_and_section_template'
require_relative 'game_parser_states/before_first_tag'
require_relative 'game_parser_states/before_tag_name'
require_relative 'game_parser_states/in_tag_name'
require_relative 'game_parser_states/before_tag_value'
require_relative 'game_parser_states/in_string'
require_relative 'game_parser_states/before_tag_close'
require_relative 'game_parser_states/between_tags'
require_relative 'game_parser_states/in_curly_comment'
require_relative 'game_parser_states/in_semicolon_comment'
require_relative 'game_parser_states/in_auction_section'
require_relative 'game_parser_states/in_play_section'
require_relative 'game_parser_states/in_supplemental_section'

# all subgame parsers implemented should be required here
require_relative 'subgame_parsers/deal_subgame_parser'
require_relative 'subgame_parsers/deal_string_parser'
require_relative 'subgame_parsers/hand_string_parser'

module PortableBridgeNotation
  module Internals
    class ConcreteFactory
      def initialize subgame_builder = SubgameBuilder.new
        @subgame_builder = subgame_builder
      end

      def make_io_parser(io)
        IoParser.new(io)
      end

      def make_cached_game_parser(pbn_game)
        @game_parser = GameParser.new pbn_game_string: pbn_game,
                                      subgame_builder: @subgame_builder,
                                      abstract_factory: self
      end

      def make_game_parser_state(class_sym, enclosing_state = nil)
        raise PortableBridgeNotationError.new('Must make a game parser prior to making states!') if @game_parser.nil?
        GameParserStates.const_get(class_sym).new(
            game_parser: @game_parser,
            subgame_builder: @subgame_builder,
            abstract_factory: self,
            enclosing_state: enclosing_state)
      end

      def make_subgame_parser(observer, tag_name)
        subgame_parser_class_for_tag_name = ''
        begin
          subgame_parser_class_for_tag_name = SubgameParsers.const_get(tag_name + 'SubgameParser')
        rescue NameError
          raise PortableBridgeNotationError.new "Unrecognized tag name: #{tag_name}"
        end
        subgame_parser_class_for_tag_name.new(self, observer)
      end

      def make_deal_string_parser(deal_string)
        DealStringParser.new(self, deal_string)
      end

      def make_hand_string_parser(hand_string)
        HandStringParser.new(hand_string)
      end

      def make_error(error_string)
        PortableBridgeNotationError.new(error_string)
      end

    end
  end
end
