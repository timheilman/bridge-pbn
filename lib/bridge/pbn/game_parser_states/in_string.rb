module Bridge
  module Pbn
    class InString
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def post_initialize
        @string = ''
        @escaped = false
      end

      def process_char(char)
        case char
          when BACKSLASH
            @string << BACKSLASH if @escaped
            @escaped = !@escaped
          when DOUBLE_QUOTE
            if @escaped
              @escaped = false
              @string << DOUBLE_QUOTE
            else
              parser.add_tag_item(@string) # todo: fix this for strings in supplemental sections
              return next_state
            end
          when TAB, LINE_FEED, VERTICAL_TAB, CARRIAGE_RETURN
            parser.raise_error "PBN-valid but string-invalid ASCII control character. Decimal code point: #{char.ord}"
          else
            @escaped = false
            @string << char
        end
        self
      end

      def finalize
        parser.raise_error "end of input in unclosed string"
      end

    end

  end
end
