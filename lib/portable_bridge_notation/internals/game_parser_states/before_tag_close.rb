require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BeforeTagClose < GameParserState
        def process_char char
          case char
            when whitespace_allowed_in_games
              return self
            when close_bracket
              return abstract_factory.make_game_parser_state :BetweenTags
            else
              game_parser.raise_error "Unexpected char other than whitespace or closing bracket: `#{char}'"
          end
        end

        def finalize
          game_parser.raise_error 'Unexpected unclosed tag.'
        end

        def add_string string
          subgame_builder.add_tag_item(string)
        end
      end
    end
  end
end
