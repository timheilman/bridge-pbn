module Bridge
  class PbnGameParser
    attr_accessor :state # temporary, hopefully
    require 'bridge/pbn/parser_states/constants'
    include Bridge::PbnParserConstants

    def each_subgame(pbn_game_string, &block)
      @pbn_game_string = pbn_game_string
      @state = :beforeFirstTag
      @block = block
      clear
      process
    end

    EMPTY_REGEXP = //

    def process
      @char_iter = @pbn_game_string.split(EMPTY_REGEXP).each_with_index
      inc_char

      while @state != :done
        case @state
          when :beforeFirstTag
            Bridge::BeforeFirstTag.new(self).process_chars
          when :beforeTagName
            Bridge::BeforeTagName.new(self).process_chars
          when :inTagName
            Bridge::InTagName.new(self).process_chars
          when :beforeTagValue
            get_into_tag_value
          when :inTagValue
            process_tag_value
          when :beforeTagClose
            get_out_of_tag
          when :outOfTag
            Bridge::BeforeFirstTag.new(self).process_chars
          when :inSupplementalSection
            process_supplemental_section
        end
      end
      yield_when_proper
    end

    def yield_when_proper
      if @tag_pair.length == 2 || @state == :done
        @block.yield PbnSubgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
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

    DOUBLE_QUOTE = '"'
    def get_into_tag_value
      case cur_char
        when ALLOWED_WHITESPACE_CHARS
          inc_char
        when DOUBLE_QUOTE
          @state = :inTagValue
          inc_char
        else
          raise_exception
      end
    end

    def process_tag_value
      process_string do |string|
        @tag_pair << string
        @state = :beforeTagClose
      end
    end

    BACKSLASH = '\\'
    NOT_DOUBLE_QUOTE = /[^"]/

    def process_string
      string = ''
      escaped = false
      until @state == :done
        case cur_char
          when BACKSLASH
            string << BACKSLASH if escaped
            escaped = !escaped
            inc_char
          when NOT_DOUBLE_QUOTE
            escaped = false
            string << cur_char
            inc_char
          when DOUBLE_QUOTE
            if escaped
              escaped = false
              string << DOUBLE_QUOTE
              inc_char
            else
              yield string
              inc_char
              break
            end
          else
            raise_exception
        end
      end
    end

    CLOSE_BRACKET = ']'
    def get_out_of_tag
      case cur_char
        when ALLOWED_WHITESPACE_CHARS
          inc_char
        when CLOSE_BRACKET
          @state = :outOfTag
          inc_char
        else
          raise_exception
      end
    end


    def process_supplemental_section
      # we must return the section untokenized, since newlines hold special meaning for ;-comments
      # and are permitted to appear in Auction and Play sections
      section_in_entirety = ''
      until @state == :done
        case cur_char
          when /[^\[\]%]/ # curly braces and semicolons must be allowed through for commentary in play and auction blocks
            section_in_entirety << cur_char
            inc_char
          when OPEN_BRACKET
            @section << section_in_entirety unless section_in_entirety.empty?
            @state = :beforeTagName
            inc_char
            return
          else
            raise_exception
        end
      end
      @section << section_in_entirety unless section_in_entirety.empty?
    end

    def raise_exception
      raise ArgumentError.new('state: ' + @state.to_s + '; string: `' +
                                  @pbn_game_string + '\'; char_index: ' + @cur_char_index.to_s)
    end

    def add_comment(comment)
      (@state == :beforeFirstTag ? @preceding_comments : @following_comments) << comment
    end

    def inc_char
      begin
        @cur_char, @cur_char_index = @char_iter.next
      rescue StopIteration
        @state = :done
      end
    end

    def cur_char
      @cur_char
    end
  end
end