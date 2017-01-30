module Bridge
  module Pbn
    class InSemicolonComment
      include GameParserState

      def post_initialize
        @comment = ''
        @prev_char_was_cr = false # fail-to-omit \r when it immediately precedes \n
      end

      def process_char(char)
        case char
          when CARRIAGE_RETURN
            perhaps_emit_cr
            @prev_char_was_cr = true
            return self
          when LINE_FEED
            finalize
            return next_state
          else
            perhaps_emit_cr
            @prev_char_was_cr = false
            @comment << char
            return self
        end
      end

      def perhaps_emit_cr
        # spec allows literally any character in comments, including CR
        if @prev_char_was_cr
          @comment << CARRIAGE_RETURN
        end
      end

      def finalize
        next_state.add_comment(@comment)
      end
    end
  end
end
