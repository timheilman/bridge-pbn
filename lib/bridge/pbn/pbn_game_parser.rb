module Bridge
  class PbnGameParser
    def each_subgame(pbn_game_string, &block)
      @pbn_game_string = pbn_game_string
      @state = :beforeFirstTag
      clear
      process(&block)
    end

    EMPTY_REGEXP = //

    def process(&block)
      @char_iter = @pbn_game_string.split(EMPTY_REGEXP).each_with_index
      inc_char

      while @state != :done
        case @state
          when :beforeFirstTag
            process_comments
          when :beforeTagName
            yield_when_proper(&block)
            get_into_tag_name
          when :inTagName
            process_tag_name
          when :beforeTagValue
            get_into_tag_value
          when :inTagValue
            process_tag_value
          when :beforeTagClose
            get_out_of_tag
          when :outOfTag
            process_comments
          when :inSupplementalSection
            process_supplemental_section
        end
      end
      yield_when_proper(&block)
    end

    def yield_when_proper(&block)
      if @tag_pair.length == 2 || @state == :done
        block.yield PbnSubgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
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
    ALLOWED_WHITESPACE_CHARS = /[ \t\v\r\n]/
    SEMICOLON = ';'
    NEWLINE_CHARACTERS = "\n" # TODO: make this configurable to be less Mac-centric
    OPEN_CURLY = '{'
    CLOSE_CURLY = '}'
    OPEN_BRACKET = '['
    SECTION_STARTING_TOKENS = /[^\[\]{\};%]/ # uh oh.  an opening square bracket within a Play section comment
    # will cause an error.  todo: TDD-fix "[ in section" bug (parse sections incl. comments)



    def process_comments
      case cur_char
        when ALLOWED_WHITESPACE_CHARS
          inc_char
        when SEMICOLON
          inc_char
          comment = ''
          while cur_char != NEWLINE_CHARACTERS && @state != :done
            comment << cur_char
            inc_char
          end
          add_comment(comment)
          inc_char
        when OPEN_CURLY
          inc_char
          comment = ''
          while cur_char != CLOSE_CURLY && @state != :done
            comment << cur_char
            inc_char
          end
          add_comment(comment)
          inc_char
        when OPEN_BRACKET
          @state = :beforeTagName
          inc_char
        when SECTION_STARTING_TOKENS
          raise_exception if @state == :beforeFirstTag
          @state = if @tag_pair[0] == 'Play'
                     :inPlaySection
                   elsif @tag_pair[0] == 'Auction'
                     :inAuctionSection
                   else
                     :inSupplementalSection
                   end
        else
          raise_exception
      end
    end

    ALLOWED_NAME_CHARS = /[A-Za-z0-9_]/

    def get_into_tag_name
      case cur_char
        when ALLOWED_WHITESPACE_CHARS
          inc_char
        when ALLOWED_NAME_CHARS
          @state = :inTagName
        else
          raise_exception
      end
    end

    def process_tag_name
      tag_name = ''
      until @state == :done || cur_char !~ ALLOWED_NAME_CHARS
        tag_name << cur_char
        inc_char
      end
      @tag_pair << tag_name
      @state = :beforeTagValue unless @state == :done
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