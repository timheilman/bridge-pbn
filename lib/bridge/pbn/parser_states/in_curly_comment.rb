module Bridge
  module Pbn
    class InCurlyComment
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def post_initialize
        @comment = ''
      end

      def process_char(char)
        char_in_latin_1 = char.encode(Encoding::ISO_8859_1)
        case char_in_latin_1
          when CLOSE_CURLY
            next_state.add_comment(@comment)
            return next_state
          else
            case char_in_latin_1.ord
              when 0..8, 12, 13..31, 127..159
                parser.raise_error "disallowed character in PBN files, decimal code: #{char_in_latin_1.ord}"
            end
            @comment << char
            return self
        end
      end

      def finalize
        parser.raise_error 'end of input within unclosed brace comment'
      end
    end
  end
end
