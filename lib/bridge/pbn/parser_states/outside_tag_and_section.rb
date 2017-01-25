module Bridge
  module Pbn
    class OutsideTagAndSection < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserDelegate

      def process_chars
        case parser.cur_char
          when ALLOWED_WHITESPACE_CHARS
            parser.inc_char
          when SEMICOLON
            parser.inc_char
            parser.state = InSemicolonComment.new(parser, self)
          when OPEN_CURLY
            parser.inc_char
            comment = ''
            while parser.cur_char != CLOSE_CURLY && !parser.state.done? # todo: fix this demeter violation
              comment << parser.cur_char
              parser.inc_char
            end
            add_comment(comment)
            parser.inc_char
          when OPEN_BRACKET
            parser.state = BeforeTagName.new(parser)
            parser.inc_char
          when SECTION_STARTING_TOKENS
            raise_exception if parser.state == BeforeFirstTag.new(parser)
            parser.state = if parser.tag_name == PLAY_SECTION_TAG_NAME
                             InPlaySection.new(parser)
                           elsif parser.tag_name == AUCTION_SECTION_TAG_NAME
                             InAuctionSection.new(parser)
                           else
                             InSupplementalSection.new(parser)
                           end
          else
            raise_exception
        end
      end

    end
  end
end
