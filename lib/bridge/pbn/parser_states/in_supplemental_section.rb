module Bridge
  module Pbn
    class InSupplementalSection < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def post_initialize
        @section = ''
      end

      def process_chars
        # we must return the section untokenized, since newlines hold special meaning for ;-comments
        # and are permitted to appear in Auction and Play sections
        case parser.cur_char
          when SECTION_INCLUDE_COMMENTS_BUGGY_HACK # curly braces and semicolons must be allowed through for commentary in play and auction blocks
            @section << parser.cur_char
            parser.inc_char
          when OPEN_BRACKET
            parser.add_section(@section) unless @section.empty?
            parser.state = BeforeTagName.new(parser)
            parser.inc_char
            return
          else
            parser.raise_exception
        end
        parser.add_section(@section) unless @section.empty?
      end
    end
  end
end
