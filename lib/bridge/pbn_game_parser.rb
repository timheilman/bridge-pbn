module Bridge
  class PbnGameParser
    class Subgame < Struct.new(:beginningComments, :tagPair, :followingComments, :section)

    end

    def each_subgame(pbn_game_string, &block)
      @pbn_game_string = pbn_game_string
      @char_index = 0
      @state = :beforeFirstTag
      @preceding_comments = []
      @tag_pair = []
      @following_comments = []
      @section = nil
      process
      block.yield Subgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
    end

    def process
      while @state == :beforeFirstTag
        process_comments
      end
      while @state == :beforeTagName
        get_into_tag_name
      end
      while @state == :inTagName
        process_tag_name
      end
      while @state == :beforeTagValue
        get_into_tag_value
      end
      while @state == :inTagValue
        process_tag_value
      end
    end

    def process_comments
      case cur_char
        when nil
          @state = :done
          return
        when /[ \t\v]/
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
        else
          raise_exception
      end
    end

    def get_into_tag_name
      case cur_char
        when /[ \t\v]/
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
        when /[ \t\v]/
          inc_char
        when '"'
          inc_char
          @state = :inTagValue
        else
          raise_exception
      end
    end

    def process_tag_value
      tag_value = ''
      # escaped = false
      until cur_char.nil?
        case cur_char
          #todo: need escaping for double-quotes in strings
          when /[^"]/
            tag_value << cur_char
            inc_char
          when '"'
            @tag_pair << tag_value
            inc_char
            @state = :beforeSection
            break
          else
            raise_exception
        end
      end
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