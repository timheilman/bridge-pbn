module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InNoteRef < GameParserState
        def post_initialize
          @note_ref_number = ''
        end

        def process_char(char)
          case char
          when digit then
            @note_ref_number << char
            self
          when equals_sign then
            finalize
            enclosing_state
          else
            game_parser.raise_error("Unexpected char in note reference: `#{char}'")
          end
        end

        def finalize
          enclosing_state.with_note_reference_number(Integer(@note_ref_number))
        end
      end
    end
  end
end
