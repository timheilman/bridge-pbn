module Bridge
  module Pbn
    class InCurlyComment < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def post_initialize
        @comment = ''
      end

      def process_chars
        case parser.cur_char
          when CLOSE_CURLY
            last_state.add_comment(@comment)
            parser.state = last_state
          else
            @comment << parser.cur_char
        end
        parser.inc_char
      end
    end
  end
end
