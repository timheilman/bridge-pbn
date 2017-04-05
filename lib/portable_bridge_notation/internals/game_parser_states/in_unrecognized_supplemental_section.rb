module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InUnrecognizedSupplementalSection < GameParserState
        attr_accessor :tag_name
        attr_accessor :tag_value
        attr_accessor :comments
        attr_accessor :section

        def post_initialize
          self.comments = []
          self.section = ''
        end

        def process_char(char)
          case char
          when open_bracket then handle_open_bracket
          when double_quote then injector.game_parser_state(:InString, self)
          when continuing_nonstring_supp_sect_char then handle_supp_section_char char
          when semicolon then handle_semicolon
          when open_curly then handle_open_curly
          else raise_error char
          end
        end

        def raise_error(char)
          err_str = "Unexpected character within a supplemental section: `#{char}'"
          game_parser.raise_error err_str
        end

        def handle_supp_section_char(char)
          section << char
          self
        end

        def handle_open_bracket
          finalize
          injector.game_parser_state(:BeforeTagName)
        end

        def handle_open_curly
          raise_error open_curly unless commentary_permitted
          self.section = ''
          return injector.game_parser_state(:InCurlyComment, self) if commentary_permitted
        end

        def handle_semicolon
          raise_error semicolon unless commentary_permitted
          self.section = ''
          return injector.game_parser_state(:InSemicolonComment, self) if commentary_permitted
        end

        def add_comment(comment)
          comments << comment
        end

        def finalize
          self.section = '' unless section =~ non_whitespace
          observer.with_unrecognized_supplemental_section(tag_name: tag_name,
                                                          tag_value: tag_value,
                                                          section: section,
                                                          comments: comments)
        end

        def add_string(string)
          section << double_quote
          section << string
          section << double_quote
        end

        def commentary_permitted
          section !~ non_whitespace
        end
      end
    end
  end
end
