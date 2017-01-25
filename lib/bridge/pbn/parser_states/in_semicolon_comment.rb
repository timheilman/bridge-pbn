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

      def process_chars
        case parser.cur_char
          when NEWLINE_CHARACTERS
            next_state.add_comment(@comment)
            parser.state = next_state
          else
            @comment << parser.cur_char
        end
        parser.inc_char
      end
    end
  end
end
