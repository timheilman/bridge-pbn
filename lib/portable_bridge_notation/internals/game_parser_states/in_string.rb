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
            when backslash
              @string << backslash if @escaped
              @escaped = !@escaped
            when double_quote
              if @escaped
                @escaped = false
                @string << double_quote
              else
                mediator.add_string(@string)
                return mediator.next_state
              end
            when tab, line_feed, vertical_tab, carriage_return
              mediator.raise_error "PBN-valid but string-invalid ASCII control character. Decimal code point: #{char.ord}"
            else
              @escaped = false
              @string << char
          end
          self
        end

        def finalize
          mediator.raise_error "end of input in unclosed string"
        end

      end
    end
  end
end
