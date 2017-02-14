require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class OutsideTagAndSectionTemplate < GameParserState

        def process_char(char)
          case char
            when whitespace_allowed_in_games
              return self
            when semicolon
              return mediator.make_game_parser_state(:InSemicolonComment, self)
            when open_curly
              return mediator.make_game_parser_state(:InCurlyComment, self)
            when open_bracket
              perhaps_yield
              return mediator.make_game_parser_state(:BeforeTagName)
            when initial_supplemental_section_char
              err_str = "Unexpected section element starting character (see PBN section 5.1) : `#{char}'"
              mediator.raise_error(err_str) unless section_tokens_allowed?
              section_state = if mediator.tag_name == 'Play' || mediator.tag_name == 'Auction'
                                mediator.reached_section(mediator.tag_name)
                              else
                                mediator.make_game_parser_state(:InSupplementalSection)
                              end
              return section_state.process_char char
            else
              err_str = "Unexpected char outside 33-126 or closing brace, closing bracket, or percent sign: `#{char}'"
              mediator.raise_error err_str
          end
        end

        def finalize
          # no-op
        end

      end
    end
  end
end
