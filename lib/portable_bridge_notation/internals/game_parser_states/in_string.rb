require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InString < GameParserState
        def post_initialize
          @string = ''
          @escaped = false
        end

        def process_char(char)
          case char
          when backslash then handle_backslash
          when double_quote then handle_double_quote
          when tab, line_feed, vertical_tab, carriage_return then raise_error char
          else
            @string << backslash if @escaped
            @escaped = false
            @string << char
            self
          end
        end

        def raise_error(char)
          game_parser.raise_error(
            "PBN-valid but string-invalid ASCII control character. Decimal code point: #{char.ord}"
          )
        end

        def handle_double_quote
          if @escaped
            @escaped = false
            @string << double_quote
            self
          else
            enclosing_state.add_string(@string.encode(Encoding::UTF_8))
            enclosing_state
          end
        end

        def handle_backslash
          @string << backslash if @escaped
          @escaped = !@escaped
          self
        end

        def finalize
          game_parser.raise_error 'end of input in unclosed string'
        end
      end
    end
  end
end
