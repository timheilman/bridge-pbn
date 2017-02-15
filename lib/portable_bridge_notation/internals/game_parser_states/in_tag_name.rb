require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InTagName < GameParserState

        def post_initialize
          @tag_name = ''
        end

        def process_char(char)
          case char
            when allowed_in_names
              @tag_name << char
              return self
            when whitespace_allowed_in_games
              subgame_builder.add_tag_item(@tag_name)
              return abstract_factory.make_game_parser_state(:BeforeTagValue)
            when double_quote
              subgame_builder.add_tag_item(@tag_name)
              return abstract_factory.make_game_parser_state(:InString, abstract_factory.make_game_parser_state(:BeforeTagClose))
            else
              game_parser.raise_error "non-whitespace, non-name character found ending tag name: #{char}"
          end
        end

        def finalize
          game_parser.raise_error 'end of input with unfinished tag name'
        end
      end
    end
  end
end
