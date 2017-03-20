require_relative 'io_parser'
require_relative 'subgame_builder'
require_relative 'game_parser'
require_relative 'portable_bridge_notation_error'
require_relative 'observer_broadcaster'
require_relative '../api/game'
require_relative 'default_game_parser_listener'

# all defined game parser states should be required here
require_relative 'game_parser_states/game_parser_state'
require_relative 'game_parser_states/before_first_tag'
require_relative 'game_parser_states/before_tag_name'
require_relative 'game_parser_states/in_tag_name'
require_relative 'game_parser_states/before_tag_value'
require_relative 'game_parser_states/in_string'
require_relative 'game_parser_states/before_tag_close'
require_relative 'game_parser_states/vacuous_section'
require_relative 'game_parser_states/in_curly_comment'
require_relative 'game_parser_states/in_semicolon_comment'
require_relative 'game_parser_states/in_auction_section'
require_relative 'game_parser_states/in_play_section'
require_relative 'game_parser_states/in_deal_section'
require_relative 'game_parser_states/in_date_section'
require_relative 'game_parser_states/in_board_section'
require_relative 'game_parser_states/in_declarer_section'
require_relative 'game_parser_states/in_unrecognized_supplemental_section'

# all subgame parsers implemented should be required here
require_relative 'subgame_parsers/subgame_parser'
require_relative 'subgame_parsers/subgame_parser_for_string_value'
require_relative 'subgame_parsers/note_subgame_parser'
require_relative 'subgame_parsers/deal_string_parser'
require_relative 'subgame_parsers/hand_string_parser'

module PortableBridgeNotation
  module Internals
    class Injector
      # arguments passed here are Spring/Guice-sense Singleton-Scoped, but needed for mocking when Injector
      # is a collaborator for the system under test
      def initialize
        super
      end

      # Spring/Guice-sense Custom-Scoped:game, assisting construction with runtime parameter pbn_game
      def game_parser(pbn_game, logger, observer)
        @observer = observer
        @game_parser = GameParser.new pbn_game_string: pbn_game,
                                      observer: observer,
                                      logger: logger,
                                      injector: self
      end

      # Spring/Guice-sense Singleton-Scoped, parameterized by type
      # this is good: singleton-scoped class lookup as is in singleton-classloader scenario: KISS.
      def subgame_parser_class_for_tag_name(tag_name)
        return SubgameParsers.const_get(tag_name + 'SubgameParser')
      rescue NameError
        raise PortableBridgeNotationError, "Unrecognized tag name: #{tag_name}"
      end

      # Spring/Guice-sense Prototype-Scoped, parameterized by type, and assisted for runtime-supplied args
      def game_parser_state(class_sym, enclosing_state = nil)
        GameParserStates.const_get(class_sym).new(
          game_parser: @game_parser,
          observer: @observer,
          injector: self,
          enclosing_state: enclosing_state
        )
      end

      # Simple Spring/Guice-sense Prototype-Scoped, not parameterized by type, and potentially assisted
      def io_parser(io)
        IoParser.new(io)
      end

      def deal_string_parser(deal_string)
        DealStringParser.new self, deal_string
      end

      def hand_string_parser(hand_string)
        HandStringParser.new hand_string
      end

      def error(error_string)
        PortableBridgeNotationError.new error_string
      end

      def observer_broadcaster
        ObserverBroadcaster.new
      end

      def game_parser_listener
        DefaultGameParserListener.new self
      end

      def game
        Api::Game.new
      end
    end
  end
end
