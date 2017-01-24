module Bridge
  module PbnParserConstants
    ALLOWED_WHITESPACE_CHARS = /[ \t\v\r\n]/
    SEMICOLON = ';'
    NEWLINE_CHARACTERS = "\n" # TODO: make this configurable to be less Mac-centric
    OPEN_CURLY = '{'
    CLOSE_CURLY = '}'
    OPEN_BRACKET = '['
    SECTION_STARTING_TOKENS = /[^\[\]{\};%]/ # uh oh.  an opening square bracket within a Play section comment
    ALLOWED_NAME_CHARS = /[A-Za-z0-9_]/
  end

  module PbnParserDelegate
    attr_reader :parser
    def initialize(parser)
      @parser = parser
    end
  end
end
