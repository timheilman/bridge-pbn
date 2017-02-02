module Bridge::Pbn
  module SingleCharComparisonConstants
    def whitespace_allowed_in_games
      /[ \t\v\r\n]/
    end

    # represents printable ASCII characters except: %;[]{}
    # note that " (\x22) *can* start a section, by starting a section element that is a string token
    def initial_supplemental_section_char
      /[\x21-\x24\x26-\x3A\x3C-\x5A\x5C\x5E-\x7A\x7C\x7E]/
    end

    def allowed_in_names
      /[A-Za-z0-9_]/
    end

    def continuing_nonstring_supp_sect_char
      /[^\]{\};%]/
    end

    def semicolon
      ';'
    end

    def carriage_return
      "\r"
    end

    def line_feed
      "\n"
    end

    def tab
      "\t"
    end

    def vertical_tab
      "\v"
    end

    def space
      ' '
    end

    def open_curly
      '{'
    end

    def close_curly
      '}'
    end

    def open_bracket
      '['
    end

    def double_quote
      '"'
    end

    def close_bracket
      ']'
    end

    def backslash
      '\\'
    end
  end
end
