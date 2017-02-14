# all defined states should be required here
require_relative 'game_parser_state_mediator'
require_relative 'game_parser_state'
require_relative 'outside_tag_and_section_template'
require_relative 'before_first_tag'
require_relative 'before_tag_name'
require_relative 'in_tag_name'
require_relative 'before_tag_value'
require_relative 'in_string'
require_relative 'before_tag_close'
require_relative 'between_tags'
require_relative 'in_curly_comment'
require_relative 'in_semicolon_comment'
require_relative 'in_auction_section'
require_relative 'in_play_section'
require_relative 'in_supplemental_section'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class GameParserStateFactory
        attr_reader :game_parser
        attr_reader :subgame_builder

        def initialize(game_parser, subgame_builder)
          @game_parser = game_parser
          @subgame_builder = subgame_builder
        end

        def make_state(class_sym, next_state = nil)
          mediator = GameParserStateMediator.new(
              game_parser: game_parser,
              subgame_builder: subgame_builder,
              game_parser_state_factory: self,
              next_state: next_state
          )
          GameParserStates.const_get(class_sym).new(mediator)
        end
      end
    end
  end
end
