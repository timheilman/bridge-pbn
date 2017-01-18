module Bridge
  # see http://www.tistis.nl/pbn/
  class Pbn
    # see section 3.4.11
    def self.deal(pbn_deal_string)
      pbn_deal_string.split(':').reduce(-1) do |startingHandIndex, firstOrHands|
        if startingHandIndex == -1
          hand_index_for_first_character(firstOrHands)
        else
          make_array_of_hands(firstOrHands, startingHandIndex)
        end
      end
    end

    def self.hand(pbn_hand_string)
      pbn_hand_string.split(/\./).reduce([]) do |cards_per_suit, ranks_string|
        suit = Bridge::Strain.suits[-cards_per_suit.length-1]
        cards_per_suit << cards_for_single_suit(ranks_string, suit)
      end.flatten
    end

    def self.import_games(io)
      # games = []
      # each_game_string(io) do |pbn_game_string|
      #   # lex first!
      #   #game_parser = Bridge::PbnGameParser.new(DealTagHandler.new)
      #   #games << pbn_game_string.each_line do |pbn_game_line|
      #     #game_parser.handle(pbn_game_line)
      #   #end
      # end
    end

    # see sections 2.4 "Escape Mechanism", 3 "Game layout", and 3.8 "Commentary"
    SEMI_EMPTY_LINE = /^[\t ]*$/
    PBN_ESCAPED_LINE = /^%/ # see section 2.4; do not confuse with Commentary from section 3.8
    def self.each_game_string(io)
      record = ''
      comment_is_open = false
      io.each do |line|
        if comment_is_open
          record << line
        elsif line =~ PBN_ESCAPED_LINE
          # potential site for processing of future directives in exported PBN files from this project
          next
        elsif line =~ SEMI_EMPTY_LINE
          yield record
          record = ''
        else
          record << line
        end
        comment_is_open = comment_open_after_eol? line, comment_is_open
      end
      yield record unless record.empty?
    end

    private

    def self.hand_index_for_first_character(first_position)
      case first_position
        when 'N'
          0
        when 'E'
          1
        when 'S'
          2
        when 'W'
          3
        else
          raise ArgumentException('bad "first" character for pgn deal string')
      end
    end

    def self.make_array_of_hands(hands, starting_hand_index)
      hands.split(' ').reduce([]) do |array_of_hands, pbn_hand_string|
        array_of_hands << (pbn_hand_string == '-' ? nil : Pbn.hand(pbn_hand_string))
      end.rotate(starting_hand_index)
    end

    def self.cards_for_single_suit(ranks_string, suit)
      ranks_string.split(//).reduce([]) do |cards, rankOfSuit|
        cards << Bridge::Card.for(ranks: [Bridge::Rank.forLetter(rankOfSuit)], suits: [suit])
      end
    end

    def self.comment_open_after_eol?(line, comment_is_open)
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
  end
end