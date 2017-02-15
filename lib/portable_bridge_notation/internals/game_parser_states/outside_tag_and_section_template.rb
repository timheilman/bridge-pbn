require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class OutsideTagAndSectionTemplate < GameParserState
        def process_char(char)
          case char
          when whitespace_allowed_in_games then self
          when semicolon then abstract_factory.make_game_parser_state(:InSemicolonComment, self)
          when open_curly then abstract_factory.make_game_parser_state(:InCurlyComment, self)
          when open_bracket then handle_open_bracket
          when initial_supplemental_section_char then start_section char
          else
            err_str = "Unexpected char outside 33-126 or closing brace, closing bracket, or percent sign: `#{char}'"
            game_parser.raise_error err_str
          end
        end

        def handle_open_bracket
          perhaps_yield
          abstract_factory.make_game_parser_state(:BeforeTagName)
        end

        def start_section(char)
          err_str = "Unexpected section element starting character (see PBN section 5.1) : `#{char}'"
          game_parser.raise_error(err_str) unless section_tokens_allowed?
          tag_name = subgame_builder.tag_name
          section_state = if tag_name == 'Play' || tag_name == 'Auction'
                            game_parser.reached_section(subgame_builder.tag_name)
                          else
                            abstract_factory.make_game_parser_state(:InSupplementalSection)
                          end
          section_state.process_char char
        end

        def finalize
          # no-op
        end
      end
    end
  end
end
