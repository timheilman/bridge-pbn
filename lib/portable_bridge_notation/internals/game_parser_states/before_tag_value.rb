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
            injector.game_parser_state(:InString, enclosing_state)
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
