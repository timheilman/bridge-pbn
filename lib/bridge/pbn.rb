module Bridge
  class Pbn
    def self.hand(pbn_hand_string)
      pbn_hand_string.split(/\./).reduce([]) do |memo, hand|
        suit = Bridge::Strain.suits[-memo.length-1]

        memo << hand.split(//).reduce([]) do |innermemo, rankOfSuit|
          innermemo << Bridge::Card.for(ranks: [Bridge::Rank.forLetter(rankOfSuit)], suits: [suit])
        end
      end.flatten
    end
  end
end