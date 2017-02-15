require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InCurlyComment < GameParserState
        def post_initialize
          @comment = ''
        end

        def process_char(char)
          case char
          when close_curly
            enclosing_state.add_comment(@comment)
            enclosing_state
          else
            @comment << char
            self
          end
        end

        def finalize
          game_parser.raise_error 'end of input within unclosed brace comment'
        end
      end
    end
  end
end
