require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BeforeTagValue < GameParserState
        def process_char(char)
          case char
          when whitespace_allowed_in_games
            self
          when double_quote
            abstract_factory
              .make_game_parser_state(:InString, abstract_factory.make_game_parser_state(:BeforeTagClose))
          else
            game_parser.raise_error "Unexpected non-whitespace, non-double quote character: `#{char}'"
          end
        end

        def finalize
          game_parser.raise_error 'end of input prior to tag value'
        end
      end
    end
  end
end
