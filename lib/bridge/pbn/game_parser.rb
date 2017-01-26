module Bridge
  module Pbn
    class GameParser
      require 'bridge/pbn/constants'
      include Bridge::Pbn::ParserConstants

      attr_writer :section

      def each_subgame(pbn_game_string, &block)
        @pbn_game_string = pbn_game_string
        @state = Bridge::Pbn::BeforeFirstTag.new(self)
        @block = block
        clear
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
        @block.yield Subgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
        clear
      end

      def clear
        @preceding_comments = []
        @tag_pair = []
        @following_comments = []
        @section = ''
      end

      # TODO: enforce 255 char cap on line width

      def tag_name
        @tag_pair[0]
      end

      def add_tag_item(tag_item)
        @tag_pair << tag_item
      end

      def raise_error(message = nil)
        raise ArgumentError.new("state: #{@state.to_s}; string: `#{@pbn_game_string}'; " +
                                    "char_index: #{@cur_char_index.to_s}; message: #{message}")
      end

      def add_preceding_comment(comment)
        @preceding_comments << comment
      end

      def add_following_comment(comment)
        @following_comments << comment
      end
    end
  end
end