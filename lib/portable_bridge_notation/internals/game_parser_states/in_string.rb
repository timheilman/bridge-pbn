require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InString < GameParserState
        attr_accessor :string
        attr_accessor :escaped

        def post_initialize
          self.string = ''
          self.escaped = false
        end

        def process_char(char)
          case char
          when backslash then handle_backslash
          when double_quote then handle_double_quote
          when tab, line_feed, vertical_tab, carriage_return then raise_error char
          else handle_default char
          end
        end

        def handle_default(char)
          string << backslash if escaped
          self.escaped = false
          string << char
          self
        end

        def raise_error(char)
          game_parser.raise_error(
            "PBN-valid but string-invalid ASCII control character. Decimal code point: #{char.ord}"
          )
        end

        def handle_double_quote
          if escaped
            self.escaped = false
            string << double_quote
            self
          else
            enclosing_state.add_string(string.encode(Encoding::UTF_8))
            enclosing_state
          end
        end

        def handle_backslash
          string << backslash if escaped
          self.escaped = !escaped
          self
        end

        def finalize
          game_parser.raise_error 'end of input in unclosed string'
        end
      end
    end
  end
end
