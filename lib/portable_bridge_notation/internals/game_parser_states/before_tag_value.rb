require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BeforeTagValue < GameParserState

        def process_char(char)
          case char
            when whitespace_allowed_in_games
              return self
            when double_quote
              return mediator.make_game_parser_state(:InString, mediator.make_game_parser_state(:BeforeTagClose))
            else
              mediator.raise_error "Unexpected non-whitespace, non-double quote character: `#{char}'"
          end
        end

        def finalize
          mediator.raise_error 'end of input prior to tag value'
        end

      end
    end
  end
end
