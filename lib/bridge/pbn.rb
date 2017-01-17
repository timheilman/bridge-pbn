module Bridge
  # see http://www.tistis.nl/pbn/
  class Pbn
    # see spec from url at top, section 3.4.11
    def self.deal(pbn_deal_string)
      pbn_deal_string.split(':').reduce(-1) do |startingHandIndex, firstOrHands|
        if startingHandIndex == -1
          hand_index_for_pgn_character(firstOrHands)
        else
          firstOrHands.split(' ').reduce([]) do |memo, pbn_hand_string|
            memo << (pbn_hand_string == '-' ? nil : Pbn.hand(pbn_hand_string))
          end.rotate(startingHandIndex)
        end
      end
    end

    def self.hand(pbn_hand_string)
      pbn_hand_string.split(/\./).reduce([]) do |memo, hand|
        suit = Bridge::Strain.suits[-memo.length-1]

        memo << hand.split(//).reduce([]) do |innermemo, rankOfSuit|
          innermemo << Bridge::Card.for(ranks: [Bridge::Rank.forLetter(rankOfSuit)], suits: [suit])
        end
      end.flatten
    end

    # see section 3 "Game layout" and section 3.8 "Commentary"
    SEMI_EMPTY_LINE = /^[\t ]*$/
    MULTILINE_COMMENT_OPEN = / {|^{/
    MULTILINE_COMMENT_CLOSE = /}/

    def self.each_game(io)
      record = ''
      comment_is_open = false
      io.each do |line|
        if comment_is_open
          record << line
        elsif line =~ SEMI_EMPTY_LINE
          yield record
          record = ''
        else
          record << line
        end
        comment_is_open = comment_open_after_end_of_line? line, comment_is_open
      end
      yield record unless record.empty?
    end

    private

    def self.comment_open_after_end_of_line?(line, comment_is_open)
      is_first_char_of_line = true
      last_char = nil
      line.split(//).each do |char|
        # see section 3.8 "Commentary"
        if char == '{' && (is_first_char_of_line == true || last_char == ' ')
          comment_is_open = true
        end
        if char == '}'
          comment_is_open = false
        end
        is_first_char_of_line = false
        last_char = char
      end
      return comment_is_open
    end

    def self.hand_index_for_pgn_character(firstPosition)
      case firstPosition
        when 'N'
          0
        when 'E'
          1
        when 'S'
          2
        when 'W'
          3
      end
    end
  end
end