module Bridge
  module Pbn
    class InTagName
      include GameParserState

      def post_initialize
        @tag_name = ''
      end

      def process_char(char)
        case char
          when ALLOWED_NAME_CHARS
            @tag_name << char
            return self
          when ALLOWED_WHITESPACE_CHARS
            builder.add_tag_item(@tag_name)
            return BeforeTagValue.new(parser, builder, self)
          when DOUBLE_QUOTE
            builder.add_tag_item(@tag_name)
            return InString.new(parser, builder, BeforeTagClose.new(parser, builder))
          else
            parser.raise_error "non-whitespace, non-name character found ending tag name: #{char}"
        end
      end

      def finalize
        parser.raise_error 'end of input with unfinished tag name'
      end
    end
  end
end
