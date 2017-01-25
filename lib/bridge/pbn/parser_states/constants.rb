module Bridge
  module Pbn
    module ParserConstants
      ALLOWED_WHITESPACE_CHARS = /[ \t\v\r\n]/
      SEMICOLON = ';'
      CARRIAGE_RETURN = "\r"
      LINE_FEED = "\n"
      OPEN_CURLY = '{'
      CLOSE_CURLY = '}'
      OPEN_BRACKET = '['
      SECTION_STARTING_TOKENS = /[^\[\]{\};%]/
      ALLOWED_NAME_CHARS = /[A-Za-z0-9_]/
      DOUBLE_QUOTE = '"'
      CLOSE_BRACKET = ']'
      ORDINARY_SECTION_TOKEN_CHARS = /[^]{\};%]/
      PLAY_SECTION_TAG_NAME = 'Play'
      AUCTION_SECTION_TAG_NAME = 'Auction'
      BACKSLASH = '\\'
      NOT_DOUBLE_QUOTE = /[^"]/
    end

    module ParserState
      attr_reader :parser
      attr_reader :next_state

      def initialize(parser, next_state = nil)
        @parser = parser
        @next_state = next_state
        if self.respond_to? :post_initialize
          post_initialize
        end
      end
    end
  end
end
