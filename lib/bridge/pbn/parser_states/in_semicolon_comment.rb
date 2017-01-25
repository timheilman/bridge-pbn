module Bridge
  module Pbn
    # despite the similarity to InCurlyComment, I'm not merging the classes yet because semicolon comments
    # need eventually to be able to deal with multicharacter line endings as their terminating symbol
    class InSemicolonComment < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def post_initialize
        @comment = ''
      end

      def process_char(char)
        case char
          when NEWLINE_CHARACTERS
            finalize
            return next_state
          else
            @comment << char
            return self
        end
        # todo: fix this for multicharacter EOL
      end

      def finalize
        next_state.add_comment(@comment)
      end
    end
  end
end
