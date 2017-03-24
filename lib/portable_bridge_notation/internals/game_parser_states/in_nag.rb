module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InNag < GameParserState
        def post_initialize
          @nag = ''
        end

        def process_char(char)
          case char
          when digit then
            @nag << char
            self
          else
            finalize
            enclosing_state.process_char char
          end
        end

        def finalize
          enclosing_state.with_nag @nag
        end
      end
    end
  end
end
