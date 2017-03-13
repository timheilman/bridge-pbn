require_relative 'io_parser'
require_relative 'subgame_builder'
require_relative 'game_parser'
require_relative 'portable_bridge_notation_error'
require_relative 'observer_broadcaster'

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
      # arguments here are Spring/Guice-sense Singleton-Scoped
      def initialize(subgame_builder = SubgameBuilder.new)
        @subgame_builder = subgame_builder
      end

      # Spring/Guice-sense Prototype-Scoped
      def make_io_parser(io)
        IoParser.new(io)
      end

      # Spring/Guice-sense Game-Parser-lifetime-Scoped
      def make_cached_game_parser(pbn_game)
        @game_parser = GameParser.new pbn_game_string: pbn_game,
                                      subgame_builder: @subgame_builder,
                                      abstract_factory: self
      end

      # Spring/Guice-sense Game-Parser-lifetime-Scoped
      def make_game_parser_state(class_sym, enclosing_state = nil)
        raise PortableBridgeNotationError, 'Must make a game parser prior to making states!' if @game_parser.nil?
        GameParserStates.const_get(class_sym).new(
          game_parser: @game_parser,
          subgame_builder: @subgame_builder,
          abstract_factory: self,
          enclosing_state: enclosing_state
        )
      end

      # Spring/Guice-sense Prototype-Scoped
      def make_subgame_parser(observer, tag_name)
        get_subgame_parser_class_for_tag_name(tag_name).new self, observer
      end

      # Spring/Guice-sense Singleton-Scoped, due to namespace lookup;
      # this is good: singleton-scoped class lookup as is in singleton-classloader scenario: KISS.
      def get_subgame_parser_class_for_tag_name(tag_name)
        return SubgameParsers.const_get(tag_name + 'SubgameParser')
      rescue NameError
        raise PortableBridgeNotationError, "Unrecognized tag name: #{tag_name}"
      end

      # Spring/Guice-sense Prototype-Scoped
      def make_deal_string_parser(deal_string)
        DealStringParser.new self, deal_string
      end

      # Spring/Guice-sense Prototype-Scoped
      def make_hand_string_parser(hand_string)
        HandStringParser.new hand_string
      end

      # Spring/Guice-sense Prototype-Scoped
      def make_error(error_string)
        PortableBridgeNotationError.new error_string
      end

      # Spring/Guice-sense Prototype-Scoped
      def make_observer_broadcaster
        ObserverBroadcaster.new
      end
    end
  end
end
