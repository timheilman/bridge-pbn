module Bridge
  module PbnParserConstants
    ALLOWED_WHITESPACE_CHARS = /[ \t\v\r\n]/
    SEMICOLON = ';'
    NEWLINE_CHARACTERS = "\n" # TODO: make this configurable to be less Mac-centric
    OPEN_CURLY = '{'
    CLOSE_CURLY = '}'
    OPEN_BRACKET = '['
    SECTION_STARTING_TOKENS = /[^\[\]{\};%]/ # uh oh.  an opening square bracket within a Play section comment
  end
end
