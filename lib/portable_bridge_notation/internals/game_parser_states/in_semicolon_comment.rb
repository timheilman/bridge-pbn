require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InSemicolonComment < GameParserState
        attr_accessor :comment
        attr_accessor :prev_char_was_cr

        def post_initialize
          self.comment = ''
          self.prev_char_was_cr = false # fail-to-omit \r when it immediately precedes \n
        end

        def process_char(char)
          case char
          when carriage_return then handle_carriage_return
          when line_feed then handle_line_feed
          else handle_other char
          end
        end

        def handle_other(char)
          perhaps_emit_cr
          self.prev_char_was_cr = false
          comment << char
          self
        end

        def handle_line_feed
          finalize
          enclosing_state
        end

        def handle_carriage_return
          perhaps_emit_cr
          self.prev_char_was_cr = true
          self
        end

        def perhaps_emit_cr
          # spec allows literally any character in comments, including CR
          comment << carriage_return if prev_char_was_cr
        end

        def finalize
          enclosing_state.add_comment(comment.encode(Encoding::UTF_8))
          enclosing_state.finalize
        end
      end
    end
  end
end
