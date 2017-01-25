module Bridge
  module Pbn
    class InString < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def post_initialize
        @string = ''
        @escaped = false
      end

      def process_chars
        case parser.cur_char
          when BACKSLASH
            @string << BACKSLASH if @escaped
            @escaped = !@escaped
            parser.inc_char
          when NOT_DOUBLE_QUOTE
            @escaped = false
            @string << parser.cur_char
            parser.inc_char
          when DOUBLE_QUOTE
            if @escaped
              @escaped = false
              @string << DOUBLE_QUOTE
              parser.inc_char
            else
              parser.add_tag_item(@string) # todo: fix this for strings in sections
              parser.inc_char
              parser.state = next_state
            end
          else
            raise_exception
        end
      end

    end

  end
end
