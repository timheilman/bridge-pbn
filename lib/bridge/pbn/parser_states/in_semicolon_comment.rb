module Bridge
  module Pbn
    # despite the similarity to InCurlyComment, I'm not merging the classes yet because semicolon comments
    # need eventually to be able to deal with multicharacter line endings as their terminating symbol
    class InSemicolonComment
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

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
            @comment << char
            return self
        end
        # todo: fix this for multicharacter EOL
      end

      def perhaps_emit_cr
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
