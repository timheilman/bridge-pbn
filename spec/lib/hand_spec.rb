def setup_zero_hcp_shape(lengths)
  let(:cards) do
    Bridge::Strain.suits.map do |suit|
      low_by_suit[suit].sample(lengths.pop)
    end.flatten
  end
end

def setup_specific_hand(pbnHandNotation)
  let(:cards) do
    #todo: split out this body to production code, potentially (for the practice) into object which passes suit
    #to a fellow member function; this will be involved in PBN import
    pbnHandNotation.split(/\./).reduce([]) do |memo, hand|
      suit = Bridge::Strain.suits[-memo.length-1]

      memo << hand.split(//).reduce([]) do |innermemo, rankOfSuit|
        innermemo << Bridge::Card.for(ranks: [Bridge::Rank.forLetter(rankOfSuit)], suits: [suit])
      end
    end.flatten
  end
end

RSpec.describe Bridge::Hand do
  let(:low_cards) { Bridge::Card.for(ranks: Bridge::Rank::Two..Bridge::Rank::Ten) }
  let(:high_by_suit) { Bridge::Card.for(ranks: Bridge::Rank::Jack..Bridge::Rank::Ace).group_by(&:suit) }
  let(:low_by_suit) { low_cards.group_by(&:suit) }

  let(:aces) { Bridge::Card.for(ranks: [Bridge::Rank::Ace]) }
  let(:kings) { Bridge::Card.for(ranks: [Bridge::Rank::King]) }
  let(:queens) { Bridge::Card.for(ranks: [Bridge::Rank::Queen]) }
  let(:jacks) { Bridge::Card.for(ranks: [Bridge::Rank::Jack]) }

  let(:cards) { Bridge::Card.all.sample(13) }
  subject(:hand) { described_class.new cards }

  describe "#shortness_points" do
    context "with no short suits" do
      setup_zero_hcp_shape([4, 3, 3, 3])
      it "returns no shortness points" do
        expect(subject.shortness_points).to eq(0)
      end
    end

    context "with one doubleton suit" do
      setup_zero_hcp_shape([4, 4, 3, 2])
      it "returns 1 shortness point" do
        expect(subject.shortness_points).to eq(1)
      end
    end

    context "with one singleton suit" do
      setup_zero_hcp_shape([4, 4, 4, 1])
      it "returns 3 shortness points" do
        expect(subject.shortness_points).to eq(3)
      end
    end

    context "with one void suit" do
      setup_zero_hcp_shape([5, 4, 4, 0])
      it "returns 5 shortness points" do
        expect(subject.shortness_points).to eq(5)
      end
    end

    context "with one of each short suit" do
      setup_specific_hand('23456789TJ.23.2.')
      it "returns 9 shortness points" do
        expect(subject.shortness_points).to eq(9)
      end
    end

    context "with spades as trump" do
      setup_specific_hand('23456789TJ.23.2.')
      let(:trump) { Bridge::Strain::Spade }
      it "does count voids outside trumps" do
        expect(subject.shortness_points trump).to eq(9)
      end
    end

    context "with clubs as trump" do
      setup_specific_hand('23456789TJ.23.2.')
      let(:trump) { Bridge::Strain::Club }
      it "doesn't count voids in trump" do
        expect(subject.shortness_points trump).to eq(4)
      end
    end
  end

  describe "#high_card_points" do
    context "with no high cards" do
      let(:cards) { low_cards.sample(13) }
      it "returns 0" do
        expect(subject.high_card_points).to eq 0
      end
    end

    context "with the best possible hand" do
      let(:cards) { aces + kings + queens + jacks.sample(1) }
      it "returns 37" do
        expect(subject.high_card_points).to eq 37
      end
    end

    context "with one ace" do
      let(:cards) { low_cards.sample(12) + aces.sample(1) }
      it "returns 4" do
        expect(subject.high_card_points).to eq 4
      end
    end

    context "with two aces" do
      let(:cards) { low_cards.sample(11) + aces.sample(2) }
      it "returns 8" do
        expect(subject.high_card_points).to eq 8
      end
    end

    context "with one king" do
      let(:cards) { low_cards.sample(12) + kings.sample(1) }
      it "returns 3" do
        expect(subject.high_card_points).to eq 3
      end
    end

    context "with one queen" do
      let(:cards) { low_cards.sample(12) + queens.sample(1) }
      it "returns 2" do
        expect(subject.high_card_points).to eq 2
      end
    end

    context "with one jack" do
      let(:cards) { low_cards.sample(12) + jacks.sample(1) }
      it "returns 1" do
        expect(subject.high_card_points).to eq 1
      end
    end

    context "with one of each high card rank" do
      let(:cards) { low_cards.sample(9) + jacks.sample(1) + aces.sample(1) + kings.sample(1) + aces.sample(1) }
      it "returns 12" do
        expect(subject.high_card_points).to eq 12
      end
    end
  end

  describe "#length_points" do
    context "with all hearts" do
      let(:cards) { low_by_suit[Bridge::Strain::Heart] + high_by_suit[Bridge::Strain::Heart] }
      it "gives 9 length points" do
        expect(subject.length_points).to eq(9)
      end
    end

    context "with no long suit" do
      setup_zero_hcp_shape([4, 3, 3, 3])
      it "returns no length points" do
        expect(subject.length_points).to eq(0)
      end
    end

    context "with one somewhat long suit" do
      setup_zero_hcp_shape([6, 2, 2, 3])
      it "returns 2 length points" do
        expect(subject.length_points).to eq(2)
      end
    end
  end

  aceOfSpades = Bridge::Card.for(suits: [Bridge::Strain::Spade], ranks: [Bridge::Rank::Ace]).first
  twoOfSpades = Bridge::Card.for(suits: [Bridge::Strain::Spade], ranks: [Bridge::Rank::Two]).first

  describe "#play" do
    setup_specific_hand('AKQJ.AKQJ.AKQ.AK')
    it "places the card in played" do
      subject.play(aceOfSpades)
      expect(subject.played).to eq([aceOfSpades])
    end
    it "fails for a card he doesn't have" do
      expect { subject.play(twoOfSpades) }.to raise_error(ArgumentError, /does not have/)
    end
    it "fails when the same card is played again" do
      expect { 2.times { subject.play(aceOfSpades) } }.to raise_error(ArgumentError, /already played/)
    end
  end

  describe "#remaining" do
    setup_specific_hand('AKQJ.AKQJ.AKQ.AK')
    it "initially has everything remaining" do
      expect(subject.remaining).to eq(cards)
    end
    it "has the remainder after a play" do
      subject.play(aceOfSpades)
      expect(subject.remaining).to eq(cards - [aceOfSpades])
    end
  end
end
