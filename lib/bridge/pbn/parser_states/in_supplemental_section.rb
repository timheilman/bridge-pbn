module Bridge
  module Pbn
    class InSupplementalSection < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def post_initialize
        @section = ''
      end

      def process_char(char)
        # we must return the section untokenized, since newlines hold special meaning for ;-comments
        # and are permitted to appear in Auction and Play sections
        case char
          when SECTION_INCLUDE_COMMENTS_BUGGY_HACK # curly braces and semicolons must be allowed through for commentary in play and auction blocks
            @section << char
            return self
          when OPEN_BRACKET
            finalize
            parser.yield_subgame
            return BeforeTagName.new(parser)
          else
            parser.raise_exception
        end
      end

      def finalize
        parser.add_section(@section) unless @section.empty?
      end
    end
  end
end
