module PortableBridgeNotation
  module Internals
    module SingleCharComparisonConstants
      def whitespace_allowed_in_games
        /[ \t\v\r\n]/
      end

      def non_whitespace
        /[^ \t\v\r\n]/
      end

      def allowed_in_names
        /[A-Za-z0-9_]/
      end

      def continuing_nonstring_supp_sect_char
        /[^\]{\};%]/
      end

      def call_char
        /[APasX1-7CDHSNT-]/
      end

      def card_char
        /[SHDCAKQJT2-9-]/
      end

      def digit
        /[0-9]/
      end

      def dollar_sign
        '$'
      end

      def equals_sign
        '='
      end

      def carat
        '^'
      end

      def plus_sign
        '+'
      end

      def exclamation_point
        '!'
      end

      def question_mark
        '?'
      end

      def asterisk
        '*'
      end

      def semicolon
        ';'
      end

      def colon
        ':'
      end

      def carriage_return
        "\r"
      end

      def line_feed
        "\n"
      end

      def form_feed
        "\f"
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

      def period
        '.'
      end

      def hyphen
        '-'
      end

      def iso_8859_1_dec_val_149
        [149].pack('C').force_encoding(Encoding::ISO_8859_1)
      end
    end
  end
end
