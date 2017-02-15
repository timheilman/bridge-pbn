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
          when allowed_in_names then handle_name_char char
          when whitespace_allowed_in_games then handle_whitespace
          when double_quote then handle_double_quote
          else
            game_parser.raise_error "non-whitespace, non-name character found ending tag name: #{char}"
          end
        end

        def handle_name_char(char)
          @tag_name << char
          self
        end

        def handle_whitespace
          subgame_builder.add_tag_item(@tag_name)
          abstract_factory.make_game_parser_state(:BeforeTagValue)
        end

        def handle_double_quote
          subgame_builder.add_tag_item(@tag_name)
          abstract_factory.make_game_parser_state(:InString, abstract_factory.make_game_parser_state(:BeforeTagClose))
        end

        def finalize
          game_parser.raise_error 'end of input with unfinished tag name'
        end
      end
    end
  end
end
