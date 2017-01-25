module Bridge
  module Pbn
    class InSupplementalSection < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserDelegate

      def process_chars
        # we must return the section untokenized, since newlines hold special meaning for ;-comments
        # and are permitted to appear in Auction and Play sections
        section_in_entirety = ''
        until parser.state.done? # todo: fix this demeter violation
          case parser.cur_char
            when SECTION_INCLUDE_COMMENTS_BUGGY_HACK # curly braces and semicolons must be allowed through for commentary in play and auction blocks
              section_in_entirety << parser.cur_char
              parser.inc_char
            when OPEN_BRACKET
              parser.add_section(section_in_entirety) unless section_in_entirety.empty?
              parser.state = BeforeTagName.new(parser)
              parser.inc_char
              return
            else
              parser.raise_exception
          end
        end
        parser.add_section(section_in_entirety) unless section_in_entirety.empty?
      end

    end
  end
end
