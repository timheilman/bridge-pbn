require 'active_support/inflector'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class VacuousSection < GameParserState
        attr_accessor :tag_name
        attr_accessor :tag_value

        def post_initialize
          @comments = []
        end

        def process_char(char)
          case char
          when whitespace_allowed_in_games then self
          when open_bracket then handle_open_bracket
          when semicolon then handle_semicolon
          when open_curly then handle_open_curly
          else raise_error char
          end
        end

        def raise_error(char)
          err_str = "Unexpected character after a tag known not to have any section data: `#{char}'"
          game_parser.raise_error err_str
        end

        def handle_open_bracket
          finalize
          injector.game_parser_state(:BeforeTagName)
        end

        def handle_open_curly
          injector.game_parser_state(:InCurlyComment, self)
        end

        def handle_semicolon
          injector.game_parser_state(:InSemicolonComment, self)
        end

        def add_comment(comment)
          @comments << comment
        end

        def emit_comments
          observer.send("with_#{tag_name.underscore}_comments", @comments) unless @comments.empty?
        end

        def finalize
          emit_comments
          # default behavior:
          observer.send("with_#{tag_name.underscore}", tag_value)
        end
      end

      class InEventSection < VacuousSection
      end
      class InSiteSection < VacuousSection
      end
      class InWestSection < VacuousSection
      end
      class InNorthSection < VacuousSection
      end
      class InEastSection < VacuousSection
      end
      class InSouthSection < VacuousSection
      end
      class InDealerSection < VacuousSection
      end
      class InVulnerableSection < VacuousSection
      end
      class InContractSection < VacuousSection
      end
      class InResultSection < VacuousSection
      end
    end
  end
end
