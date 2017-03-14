module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class NoteSubgameParser < SubgameParser
        def parse(subgame)
          note_parts = subgame.tagPair[1].split(':')
          note_index = Integer(note_parts[0])
          note_text = note_parts[1..note_parts.length].join(':')
          @game_parser.add_note_ref_resolution(note_index, note_text)
        end
      end
    end
  end
end
