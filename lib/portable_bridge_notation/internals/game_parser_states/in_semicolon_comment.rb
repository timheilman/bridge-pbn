require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InSemicolonComment < GameParserState
        def post_initialize
          @comment = ''
          @prev_char_was_cr = false # fail-to-omit \r when it immediately precedes \n
        end

        def process_char(char)
          case char
          when carriage_return
            perhaps_emit_cr
            @prev_char_was_cr = true
            self
          when line_feed
            finalize
            enclosing_state
          else
            perhaps_emit_cr
            @prev_char_was_cr = false
            @comment << char
            self
          end
        end

        def perhaps_emit_cr
          # spec allows literally any character in comments, including CR
          @comment << carriage_return if @prev_char_was_cr
        end

        def finalize
          enclosing_state.add_comment(@comment)
        end
      end
    end
  end
end
