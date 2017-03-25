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

      %w(
        Annotator
        AnnotatorNA
        BidSystemEW
        BidSystemNS
        Competition
        Contract
        Dealer
        Description
        East
        EastNA
        EastType
        Event
        EventSponsor
        FrenchMP
        Generator
        Hidden
        HomeTeam
        Mode
        North
        NorthNA
        NorthType
        Result
        Room
        Round
        ScoreRubber
        Scoring
        Section
        Site
        South
        SouthNA
        SouthType
        Stage
        Table
        Termination
        TimeControl
        VisitTeam
        West
        WestNA
        WestType
      ).each { |classname| module_eval 'In' + classname + 'Section = VacuousSection' }
    end
  end
end
