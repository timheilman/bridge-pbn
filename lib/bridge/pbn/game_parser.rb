module Bridge::Pbn
  class GameParser
    include SingleCharComparisonConstants

    # TODO: enforce section continuity (no identification section tags both before and after play/auction/supplemental)
    # TODO: enforce 255 char cap on line width
    # TODO: Evans feedback on command/query mix here: Make c'tor w/builder or abstract factory pattern for self vars
    def each_subgame(pbn_game_string, &block)
      @pbn_game_string = pbn_game_string
      @builder = SubgameBuilder.new
      @state = GameParserStates::BeforeFirstTag.new(self, @builder)
      @block = block
      @builder.clear
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
        #todo: eliminate this non-event, non-question, non-transformation monadic form:
        # @state has an implicit dual responsibility here: the side effects from the event
        # that a character has been read from the game stream, one side effect of which may or may not be
        # the alteration of what state is held by GameParser
        # replace with state update message from the state to the mediator (or parser if not yet mediated)
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

  end
end