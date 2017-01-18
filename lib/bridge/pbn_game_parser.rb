module Bridge
  class PbnGameParser
    class Subgame < Struct.new(:beginningComments, :tagPair, :followingComments, :section)
      def inspect
        return 'bc: ' + @beginningComments.to_s +
            ' tp: ' + @tagPair.to_s +
            ' fc: ' + @followingComments.to_s +
            ' s: ' + section
      end
    end

    def each_subgame(pbn_game_string, &block)
      @pbn_game_string = pbn_game_string
      @char_index = 0
      @state = :beforeFirstTag
      clear
      process(&block)
    end

    def process(&block)
      while @state != :done
        case @state
          when :beforeFirstTag
            process_comments
          when :beforeTagName
            do_yield(&block)
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
          when :inSection
            process_section
        end
      end
      do_yield(&block)
    end

    def do_yield(&block)
      if @tag_pair.length == 2 || @state == :done
        block.yield Subgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
        clear
      end
    end

    def clear
      @preceding_comments = []
      @tag_pair = []
      @following_comments = []
      @section = ''
    end

    def process_comments
      case cur_char
        when nil
          @state = :done
          return
        when /[ \t\v\r\n]/
          inc_char
        when ';'
          inc_char
          comment = ''
          while !cur_char.nil? && cur_char != "\n"
            comment << cur_char
            inc_char
          end
          add_comment(comment)
          inc_char unless cur_char.nil?
        when '{'
          inc_char
          comment = ''
          while cur_char != '}'
            comment << cur_char
            inc_char
          end
          add_comment(comment)
          inc_char
        when '['
          @state = :beforeTagName
          inc_char
        when /[^\[\]{\};%]/
          raise_exception if @state == :beforeFirstTag
          @state = :inSection
        else
          raise_exception
      end
    end

    def get_into_tag_name
      case cur_char
        when /[ \t\v\r\n]/
          inc_char
        when /[A-Za-z0-9_]/
          @state = :inTagName
        else
          raise_exception
      end
    end

    def process_tag_name
      tag_name = ''
      until cur_char.nil?
        case cur_char
          when /[A-Za-z0-9_]/
            tag_name << cur_char
            inc_char
          else
            @tag_pair << tag_name
            @state = :beforeTagValue
            break
        end
      end
    end

    def get_into_tag_value
      case cur_char
        when /[ \t\v\r\n]/
          inc_char
        when '"'
          inc_char
          @state = :inTagValue
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

    def process_string
      string = ''
      escaped = false
      until cur_char.nil?
        case cur_char
          when '\\'
            string << '\\' if escaped
            escaped = !escaped
            inc_char
          when /[^"]/
            escaped = false
            string << cur_char
            inc_char
          when '"'
            if escaped
              escaped = false
              string << '"'
              inc_char
            else
              inc_char
              yield string
              break
            end
          else
            raise_exception
        end
      end
    end

    def get_out_of_tag
      case cur_char
        when /[ \t\v\r\n]/
          inc_char
        when ']'
          inc_char
          @state = :outOfTag
        else
          raise_exception
      end
    end


    def process_section
      # we must return the section untokenized, since newlines hold special meaning for ;-comments
      # and are permitted to appear in Auction and Play sections
      section_in_entirety = ''
      until cur_char.nil?
        case cur_char
          when /[^\[\]%]/ # curly braces and semicolons must be allowed through for commentary in play and auction blocks
            section_in_entirety << cur_char
            inc_char
          when '['
            @section << section_in_entirety unless section_in_entirety.empty?
            inc_char
            @state = :beforeTagName
            return
          else
            raise_exception
        end
      end
      @state = :done
      @section << section_in_entirety unless section_in_entirety.empty?
    end

    def raise_exception
      raise ArgumentError.new('state: ' + @state.to_s + '; string: `' +
                                  @pbn_game_string + '\'; char_index: ' + @char_index.to_s)
    end

    def add_comment(comment)
      (@state == :beforeFirstTag ? @preceding_comments : @following_comments) << comment
    end

    def inc_char
      @char_index += 1
    end

    def cur_char
      @pbn_game_string[@char_index]
    end
  end
end