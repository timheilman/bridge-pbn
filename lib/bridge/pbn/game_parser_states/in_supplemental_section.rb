module Bridge
  module Pbn
    class InSupplementalSection
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def post_initialize
        @section = ''
      end

      def process_char(char)
        # we are returning the section exactly as-provided, in order for custom supplemental sections
        # to be parsed in custom ways
        case char
          when OPEN_BRACKET
            finalize
            parser.yield_subgame
            return BeforeTagName.new(parser)
          when DOUBLE_QUOTE
            return InString.new(parser, self)
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

      def add_string(string)
        @section << DOUBLE_QUOTE
        @section << string
        @section << DOUBLE_QUOTE
      end
    end
  end
end
