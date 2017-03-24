module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InIrregularity < GameParserState
        def process_char(char)
          case char
          when 'I' then enclosing_state.with_insufficiency_irregularity
          when 'S' then enclosing_state.with_skipped_player_irregularity
          when 'R' then enclosing_state.with_revoke_irregularity
          when 'L' then enclosing_state.with_lead_irregularity
          else game_parser.raise_error "Unexpected irregularity char `#{char}'"
          end
          enclosing_state
        end
      end
    end
  end
end
