RSpec.describe Bridge::Hand do
  let(:low_cards)    { Bridge::Card.for(ranks:    Bridge::Rank::Two..Bridge::Rank::Ten)                   }
  let(:high_by_suit) { Bridge::Card.for(ranks:    Bridge::Rank::Jack..Bridge::Rank::Ace).group_by(&:suit) }
  let(:low_by_suit)  { low_cards.group_by(&:suit) }

  let(:aces)   { Bridge::Card.for(ranks: [Bridge::Rank::Ace])   }
  let(:kings)  { Bridge::Card.for(ranks: [Bridge::Rank::King])  }
  let(:queens) { Bridge::Card.for(ranks: [Bridge::Rank::Queen]) }
  let(:jacks)  { Bridge::Card.for(ranks: [Bridge::Rank::Jack])  }

  let(:cards) { Brige::Card.all.sample(13) }
  subject(:hand) { described_class.new cards }

  describe "#short_points" do
    context "with no short suits" do
      let(:cards) do
        lengths = [4,3,3,3]
        Bridge::Strain.card.map do |suit|
          low_by_suit[suit].sample(lengths.pop)
        end.flatten
      end
      it "returns no short points" do
        expect(subject.short_points).to eq(0)
      end
    end

    context "with one doubleton suit" do
      let(:cards) do
        lengths = [4,4,3,2]
        Bridge::Strain.card.map do |suit|
          low_by_suit[suit].sample(lengths.pop)
        end.flatten
      end
      it "returns 1 short point" do
        expect(subject.short_points).to eq(1)
      end
    end

    context "with one singleton suit" do
      let(:cards) do
        lengths = [4,4,4,1]
        Bridge::Strain.card.map do |suit|
          low_by_suit[suit].sample(lengths.pop)
        end.flatten
      end
      it "returns 3 short points" do
        expect(subject.short_points).to eq(3)
      end
    end

    context "with one void suit" do
      let(:cards) do
        lengths = [5,4,4,0]
        Bridge::Strain.card.map do |suit|
          low_by_suit[suit].sample(lengths.pop)
        end.flatten
      end
      it "returns 5 short points" do
        expect(subject.short_points).to eq(5)
      end
    end

    context "with one of each short suit" do
      let(:cards) do
        lengths = [9,2,1,0]
        suits = Bridge::Strain.card
        suits.map do |suit|
          low_by_suit[suit].sample(lengths.shift)
        end.flatten + high_by_suit[suits.first].sample(1)
      end
      it "returns 9 short points" do
        expect(subject.short_points).to eq(9)
      end
    end

    context "with a trump suit" do
      let(:trump) { Bridge::Strain.card.first }
      let(:cards) do
        lengths = [9,2,1,0]
        suits = Bridge::Strain.card
        suits.map do |suit|
          low_by_suit[suit].sample(lengths.pop)
        end.flatten + high_by_suit[suits.last].sample(1)
      end
      it "returns does not count a void in trump" do
        expect(subject.short_points).to eq(9)
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

  describe "#long_points" do
    context "with all hearts" do
      let(:cards) { low_by_suit[Bridge::Strain::Heart] + high_by_suit[Bridge::Strain::Heart] }
      it "gives 9 long points" do
        expect(subject.long_points).to eq(9)
      end
    end

    context "with no long suit" do
      let(:cards) do
        lengths = [4,3,3,3]
        Bridge::Strain.card.map do |suit|
          low_by_suit[suit].sample(lengths.pop)
        end.flatten
      end
      it "returns no long points" do
        expect(subject.long_points).to eq(0)
      end
    end

    context "with one somewhat long suit" do
      let(:cards) do
        lengths = [6,2,2,3]
        Bridge::Strain.card.map do |suit|
          low_by_suit[suit].sample(lengths.pop)
        end.flatten
      end
      it "returns 2 long points" do
        expect(subject.long_points).to eq(2)
      end
    end
  end
end
