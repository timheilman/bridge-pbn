module Bridge
  module Pbn
    class InTagValue < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_chars
        parser.process_string do |string|
          parser.add_tag_item(string)
          parser.state = BeforeTagClose.new(parser)
        end

      end
    end
  end
end
