module Bridge
  module Pbn
    class BeforeTagValue
      include GameParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when DOUBLE_QUOTE
            return InString.new(parser, builder, BeforeTagClose.new(parser, builder))
          else
            parser.raise_error "Unexpected non-whitespace, non-double quote character: `#{char}'"
        end
      end

      def finalize
        parser.raise_error 'end of input prior to tag value'
      end

    end
  end
end
