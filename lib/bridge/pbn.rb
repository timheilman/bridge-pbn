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

    private

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