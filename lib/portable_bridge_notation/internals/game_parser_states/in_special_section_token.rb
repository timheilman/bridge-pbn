module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InSpecialSectionToken < GameParserState
        def post_initialize
          @special_token = ''
        end

        def process_char(char)
          case char
          when whitespace_allowed_in_games, dollar_sign, equals_sign, question_mark, exclamation_point
            finalize
            enclosing_state.process_char char
          when special_token_char
            @special_token << char
            self
          else
            game_parser.raise_error "Unexpected character within a Call: #{char}"
          end
        end

        def finalize
          enclosing_state.with_special_section_token @special_token
        end
      end
      class InCall < InSpecialSectionToken
        def special_token_char
          call_char
        end
      end
      class InCard < InSpecialSectionToken
        def special_token_char
          card_char
        end
      end
    end
  end
end
