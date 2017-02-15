require_relative 'game_parser'
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
module PortableBridgeNotation
  module Internals
    class GameParserFactory
      attr_reader :game_parser # todo: are these needed?
      attr_reader :subgame_builder

      def initialize(game_parser_class: GameParser,
                     subgame_builder:)
        @game_parser_class = game_parser_class
        @subgame_builder = subgame_builder
      end

      def make_cached_game_parser(pbn_game)
        @game_parser = @game_parser_class.new pbn_game_string: pbn_game,
                                              subgame_builder: @subgame_builder,
                                              game_parser_factory: self
      end


      def make_game_parser_state(class_sym, enclosing_state = nil)
        raise_error if @game_parser.nil?
        GameParserStates.const_get(class_sym).new(
            game_parser: @game_parser,
            subgame_builder: @subgame_builder,
            game_parser_factory: self,
            enclosing_state: enclosing_state)
      end

      def raise_error
        raise PortableBridgeNotationError.new('Must make a game parser prior to making states!')
      end

    end
  end
end
