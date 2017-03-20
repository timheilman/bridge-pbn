module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InNoteSection < VacuousSection
        def finalize
          emit_comments
          note_parts = tag_value.split(':')
          note_index = Integer(note_parts[0])
          note_text = note_parts[1..note_parts.length].join(':')
          @game_parser.add_note_ref_resolution(note_index, note_text)
        end
      end
    end
  end
end
