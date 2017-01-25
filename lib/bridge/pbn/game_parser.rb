module Bridge
  module Pbn
    class GameParser
      attr_accessor :state # temporary, hopefully
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
        @char_iter = @pbn_game_string.split(EMPTY_REGEXP).each_with_index
        inc_char

        until @state.done?
          @state.process_chars
        end
        yield_when_proper
      end

      def yield_when_proper
        if @tag_pair.length == 2 || @state.done?
          @block.yield Subgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
          clear
        end
      end

      def clear
        @preceding_comments = []
        @tag_pair = []
        @following_comments = []
        @section = ''
      end

      #TODO: enforce 255 char cap
      # will cause an error.  todo: TDD-fix "[ in section" bug (parse sections incl. comments)


      def tag_name
        @tag_pair[0]
      end

      def add_tag_item tag_item
        @tag_pair << tag_item
      end


      def add_section(section)
        @section = section
      end

      def raise_exception(message = nil)
        raise ArgumentError.new("state: #{@state.to_s}; string: `#{@pbn_game_string}'; " +
                                    "char_index: #{@cur_char_index.to_s}; message: #{message}")
      end

      def add_preceding_comment(comment)
        @preceding_comments << comment
      end

      def add_following_comment(comment)
        @following_comments << comment
      end

      def inc_char
        begin
          @cur_char, @cur_char_index = @char_iter.next
        rescue StopIteration
          @state = Bridge::Pbn::Done.new
        end
      end

      def cur_char
        @cur_char
      end
    end
  end
end