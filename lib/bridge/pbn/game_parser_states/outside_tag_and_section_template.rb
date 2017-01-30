module Bridge
  module Pbn
    class OutsideTagAndSectionTemplate
      include GameParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when SEMICOLON
            return InSemicolonComment.new(parser, builder, self)
          when OPEN_CURLY
            return InCurlyComment.new(parser, builder, self)
          when OPEN_BRACKET
            perhaps_yield
            return BeforeTagName.new(parser, builder)
          when SECTION_STARTING_CHARS
            err_str = "Unexpected section element starting character (see PBN section 5.1) : `#{char}'"
            parser.raise_error(err_str) unless section_tokens_allowed
            section_state = if builder.tag_name == PLAY_SECTION_TAG_NAME
                             InPlaySection.new(parser, builder)
                           elsif builder.tag_name == AUCTION_SECTION_TAG_NAME
                             InAuctionSection.new(parser, builder)
                           else
                             InSupplementalSection.new(parser, builder)
                           end
            return section_state.process_char char
          else
            err_str = "Unexpected char outside 33-126 or closing brace, closing bracket, or percent sign: `#{char}'"
            parser.raise_error err_str
        end
      end

      def finalize
        # no-op
      end

    end
  end
end
