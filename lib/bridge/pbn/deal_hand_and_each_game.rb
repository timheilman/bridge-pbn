module Bridge
  module Pbn
    # see http://www.tistis.nl/pbn/
    class DealHandAndEachGame
      COLON = ':'
      PRE_COLON_INDICATOR = -1
      PERIOD = '.'
      # see section 3.4.11
      def self.deal(pbn_deal_string)
        pbn_deal_string.split(COLON).reduce(PRE_COLON_INDICATOR) do |startingHandIndex, firstOrHands|
          if startingHandIndex == PRE_COLON_INDICATOR
            hand_index_for_first_character(firstOrHands)
          else
            make_array_of_hands(firstOrHands, startingHandIndex)
          end
        end
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

      # see sections 2.4 "Escape Mechanism", 3 "Game layout", and 3.8 "Commentary"
      SEMI_EMPTY_LINE = /^[\t ]*$/
      PBN_ESCAPED_LINE = /^%/ # see section 2.4; do not confuse with Commentary from section 3.8
      def self.each_game_string(io)
        record = ''
        comment_is_open = false
        io.set_encoding(Encoding::ISO_8859_1) # unfortunate but that's the spec!
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
            raise ArgumentError.new("bad first position character for pgn deal string: `#{first_position}'")
        end
      end

      SPACE = ' '
      HYPHEN = '-'

      def self.make_array_of_hands(hands, starting_hand_index)
        hands.split(SPACE).reduce([]) do |array_of_hands, pbn_hand_string|
          array_of_hands << (pbn_hand_string == HYPHEN ? nil : DealHandAndEachGame.hand(pbn_hand_string))
        end.rotate(starting_hand_index)
      end

      def self.cards_for_single_suit(ranks_string, suit)
        ranks_string.each_char.reduce([]) do |cards, rankOfSuit|
          cards << Bridge::Card.for(ranks: [Bridge::Rank.for_char(rankOfSuit)], suits: [suit])
        end
      end

      OPEN_CURLY = '{'
      CLOSE_CURLY = '}'

      def self.comment_open_after_eol?(line, comment_is_open)
        last_char = nil
        line.each_char do |char|
          # see section 3.8 "Commentary"
          if char == OPEN_CURLY && (last_char.nil? || last_char == SPACE)
            comment_is_open = true
          end
          if char == CLOSE_CURLY
            comment_is_open = false
          end
          last_char = char
        end
        return comment_is_open
      end
    end
  end
end