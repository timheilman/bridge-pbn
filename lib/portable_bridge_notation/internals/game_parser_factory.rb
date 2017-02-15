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
    module GameParserStates
      class GameParserFactory
        attr_reader :game_parser
        attr_reader :subgame_builder

        def initialize(game_parser:, subgame_builder:)
          @game_parser = game_parser
          @subgame_builder = subgame_builder
        end

        def make_game_parser_state(class_sym, enclosing_state = nil)
          GameParserStates.const_get(class_sym).new(
              game_parser: game_parser,
              subgame_builder: subgame_builder,
              game_parser_state_factory: self,
              enclosing_state: enclosing_state)
        end
      end
    end
  end
end
