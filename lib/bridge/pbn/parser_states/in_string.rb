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

      def process_char(char)
        case char
          when BACKSLASH
            @string << BACKSLASH if @escaped
            @escaped = !@escaped
          when NOT_DOUBLE_QUOTE
            @escaped = false
            @string << char
          when DOUBLE_QUOTE
            if @escaped
              @escaped = false
              @string << DOUBLE_QUOTE
            else
              parser.add_tag_item(@string) # todo: fix this for strings in supplemental sections
              return next_state
            end
            #cases are exhaustive; no else needed
        end
        self
      end

    end

  end
end
