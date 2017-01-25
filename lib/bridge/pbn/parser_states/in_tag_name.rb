module Bridge
  module Pbn
    class InTagName < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def post_initialize
        @tag_name = ''
      end

      def process_chars
        case parser.cur_char
          when ALLOWED_NAME_CHARS
            @tag_name << parser.cur_char
          else
            parser.add_tag_item(@tag_name)
            parser.state = BeforeTagValue.new(parser, self)
        end
        parser.inc_char
      end
    end
  end
end
