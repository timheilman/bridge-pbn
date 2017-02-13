require_relative 'single_char_comparison_constants'
require_relative 'subgame_builder'
require_relative 'game_parser_states/game_parser_state_factory'
class PortableBridgeNotation::GameParser
  include PortableBridgeNotation::SingleCharComparisonConstants

  # TODO: enforce section continuity (no identification section tags both before and after play/auction/supplemental)
  # TODO: enforce 255 char cap on line width
  # TODO: Evans feedback on command/query mix here: Make c'tor w/builder or abstract factory pattern for self vars
  def each_subgame(pbn_game_string, &block)
    @pbn_game_string = pbn_game_string
    @builder = PortableBridgeNotation::SubgameBuilder.new
    @state = PortableBridgeNotation::GameParserStates::GameParserStateFactory.
        new(self, @builder).make_state(:BeforeFirstTag)
    @block = block
    @builder.clear
    @section_notes = {}
    process
  end

  def process
    @pbn_game_string.each_char.with_index do |char, index|
      @cur_char_index = index
      case (char.encode(Encoding::ISO_8859_1).ord)
        # intent: couldn't figure out how to do non-ascii by ordinal in a regexp; fell back to this
        # 9 is \t
        # 10 is \n
        # 11 is \v
        # 13 is \r
        # 32-126 are ASCII printable
        # 160-255 are non-ASCII printable
        when 0..8, 12, 14..31, 127..159
          raise_error "disallowed character in PBN files, decimal code: #{char.ord}"
      end
      @state = @state.process_char(char)
    end
    @state.finalize
    yield_subgame
  end

  def yield_subgame
    @block.yield @builder.build
    @builder.clear
  end

  def raise_error(message = nil)
    raise ArgumentError.new("state: #{@state.to_s}; string: `#{@pbn_game_string}'; " +
                                "char_index: #{@cur_char_index.to_s}; message: #{message}")
  end

  def reached_section(section_name)
    @section_name = section_name
    @section_notes.merge! section_name => {}
  end

  # todo: to be called from NoteSubgameParser
  def add_note_ref_resolution(ref_num, text)
    @section_notes[@section_name].merge! ref_num => text
  end
end