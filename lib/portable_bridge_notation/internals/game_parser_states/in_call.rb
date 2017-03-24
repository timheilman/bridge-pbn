module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InCall < GameParserState
        def post_initialize
          @call = ''
        end

        def process_char(char)
          case char
          when whitespace_allowed_in_games, dollar_sign, equals_sign, question_mark, exclamation_point
            finalize
            enclosing_state.process_char char
          when call_char
            @call << char
            self
          else
            game_parser.raise_error "Unexpected character within a Call: #{char}"
          end
        end

        def finalize
          enclosing_state.with_call @call
        end
      end
    end
  end
end
