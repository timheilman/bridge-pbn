module Bridge
  module Pbn
    class GameParser
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants

      def each_subgame(pbn_game_string, &block)
        @pbn_game_string = pbn_game_string
        @state = Bridge::Pbn::BeforeFirstTag.new(self)
        @block = block
        clear
        process
      end

      def process
        @pbn_game_string.each_char do |char, index|
          @cur_char_index = index
          @state = @state.process_char(char)
        end
        @state.finalize
        # todo: verify that @state is a proper value and raise an exception otherwise
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

      #TODO: enforce 255 char cap
      # will cause an error.  todo: TDD-fix "[ in section" bug (parse suppl. sections incl. strings)


      def tag_name
        @tag_pair[0]
      end

      def add_tag_item(tag_item)
        @tag_pair << tag_item
      end


      def set_section(section)
        @section = section
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