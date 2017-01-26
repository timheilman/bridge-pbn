module Bridge
  module Pbn
    class InSupplementalSection
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def post_initialize
        @section = ''
      end

      def process_char(char)
        # we are returning the section untokenized for now; potential future direction is to have supplemental
        # sections parsed specifically and error- or warning-out for unrecognized supplemental sections
        # todo: fix bug wherein strings containing disallowed characters raise an error
        case char
          when OPEN_BRACKET
            finalize
            parser.yield_subgame
            return BeforeTagName.new(parser)
          when ORDINARY_SECTION_TOKEN_CHARS
            @section << char
            return self
          else
            parser.raise_error "Unexpected character within a supplemental section: `#{char}'"
        end
      end

      def finalize
        parser.section = @section unless @section.empty?
      end
    end
  end
end
