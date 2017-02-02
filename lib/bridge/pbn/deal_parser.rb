module Bridge::Pbn
  # see http://www.tistis.nl/pbn/
  class DealParser

    COLON = ':'
    PERIOD = '.'
    # see section 3.4.11
    def self.deal(pbn_deal_string)
      left_and_right_of_colon = pbn_deal_string.split(COLON)
      make_array_of_hands(left_and_right_of_colon[1], hand_index_for_first_character(left_and_right_of_colon[0]))
    end


    def self.hand(pbn_hand_string)
      pbn_hand_string.split(PERIOD).reduce([]) do |cards_per_suit, ranks_string|
        suit = Bridge::Strain.suits[suit_index_for_output_length(cards_per_suit.length)]
        cards_per_suit << cards_for_single_suit(ranks_string, suit)
      end.flatten
    end

    # readability method
    def self.suit_index_for_output_length(output_length)
      -output_length-1
    end

    def self.import_games(io)
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
          raise ArgumentError.new("bad first position character for pgn deal string: `#{first_position}'")
      end
    end

    SPACE = ' '
    HYPHEN = '-'

    def self.make_array_of_hands(hands, starting_hand_index)
      hands.split(SPACE).reduce([]) do |array_of_hands, pbn_hand_string|
        array_of_hands << (pbn_hand_string == HYPHEN ? nil : DealParser.hand(pbn_hand_string))
      end.rotate(starting_hand_index)
    end

    def self.cards_for_single_suit(ranks_string, suit)
      ranks_string.each_char.reduce([]) do |cards, rankOfSuit|
        cards << Bridge::Card.for(ranks: [Bridge::Rank.for_char(rankOfSuit)], suits: [suit])
      end
    end
  end
end