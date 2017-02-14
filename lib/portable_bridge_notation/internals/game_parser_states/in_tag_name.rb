require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InTagName < GameParserState

        def post_initialize
          @tag_name = ''
        end

        def process_char(char)
          case char
            when allowed_in_names
              @tag_name << char
              return self
            when whitespace_allowed_in_games
              mediator.add_tag_item(@tag_name)
              return mediator.make_state(:BeforeTagValue)
            when double_quote
              mediator.add_tag_item(@tag_name)
              return mediator.make_state(:InString, mediator.make_state(:BeforeTagClose))
            else
              mediator.raise_error "non-whitespace, non-name character found ending tag name: #{char}"
          end
        end

        def finalize
          mediator.raise_error 'end of input with unfinished tag name'
        end
      end
    end
  end
end
