module Bridge
  module Pbn
    class OutsideTagAndSectionTemplate < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when SEMICOLON
            return InSemicolonComment.new(parser, self)
          when OPEN_CURLY
            return InCurlyComment.new(parser, self)
          when OPEN_BRACKET
            perhaps_yield
            return BeforeTagName.new(parser)
          when SECTION_STARTING_TOKENS
            parser.raise_error unless section_tokens_allowed
            section_state = if parser.tag_name == PLAY_SECTION_TAG_NAME
                             InPlaySection.new(parser)
                           elsif parser.tag_name == AUCTION_SECTION_TAG_NAME
                             InAuctionSection.new(parser)
                           else
                             InSupplementalSection.new(parser)
                           end
            return section_state.process_char char
          else
            parser.raise_error
        end
      end

    end
  end
end
