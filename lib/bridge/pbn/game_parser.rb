module Bridge
  module Pbn
    class GameParser
      include ParserConstants

      # TODO: enforce 255 char cap on line width
      def each_subgame(pbn_game_string, &block)
        @pbn_game_string = pbn_game_string
        @builder = Bridge::Pbn::SubgameBuilder.new
        @state = Bridge::Pbn::BeforeFirstTag.new(self, @builder)
        @block = block
        @builder.clear
        process
      end

      def process
        @pbn_game_string.each_char.with_index do |char, index|
          @cur_char_index = index
          case (char.encode(Encoding::ISO_8859_1).ord)
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

    end
  end
end