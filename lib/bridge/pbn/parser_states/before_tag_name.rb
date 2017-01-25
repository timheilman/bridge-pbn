module Bridge
  module Pbn
    class BeforeTagName < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_chars
        parser.yield_when_proper
        get_into_tag_name
      end

      def get_into_tag_name
        case parser.cur_char
          when ALLOWED_WHITESPACE_CHARS
            parser.inc_char
          when ALLOWED_NAME_CHARS
            in_tag_name = InTagName.new(parser)
            parser.state = in_tag_name # will make the call directly here since no inc
          else
            parser.raise_exception
        end
      end

    end
  end
end