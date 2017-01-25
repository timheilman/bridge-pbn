require 'spec_helper'

def cards_for(*cards)
  result = []
  cards.each do |rankAndSuit|
    rank = rankAndSuit.split(//)[0]
    suit = rankAndSuit.split(//)[1]
    result << Bridge::Card.for(suits: [Bridge::Strain.for_string(suit)], ranks: [Bridge::Rank.for_char(rank)]).first
  end
  result
end

def let_expected_hands
  let(:expectedNHand) {
    cards_for('6H', '3H',
              'AD', 'KD', 'QD', '9D', '8D', '7D',
              'AC', '9C', '7C', '3C', '2C') }
  let(:expectedEHand) {
    cards_for('AS', '8S', '6S', '5S', '4S',
              'KH', 'QH', '5H',
              'TD',
              'QC', 'JC', 'TC', '6C') }
  let(:expectedSHand) {
    cards_for('JS', '9S', '7S', '3S',
              'JH', '9H', '8H', '7H', '4H', '2H',
              '3D',
              'KC', '4C') }
  let(:expectedWHand) {
    cards_for('KS', 'QS', 'TS', '2S',
              'AH', 'TH',
              'JD', '6D', '5D', '4D', '2D',
              '8C', '5C') }
end

RSpec.describe Bridge::Pbn::DealHandAndEach do

  describe '.hand' do
    let_expected_hands
    let(:hand) { '.63.AKQ987.A9732' }
    it 'returns the hand we expect' do
      expect(described_class.hand(hand)).to eq(expectedNHand)
    end
  end

  describe '.deal' do
    let_expected_hands
    context 'with N first' do
      let(:deal) { 'N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }

      it 'returns the game we expect' do
        expect(described_class.deal deal).to eq([expectedNHand, expectedEHand, expectedSHand, expectedWHand])
      end
    end
    context 'with E first' do
      let(:deal) { 'E:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }
      it 'returns the same game with the hands rotated clockwise once' do
        expect(described_class.deal deal).to eq([expectedEHand, expectedSHand, expectedWHand, expectedNHand])
      end
    end
    context 'with S first' do
      let(:deal) { 'S:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }
      it 'returns the same game with the hands rotated clockwise twice' do
        expect(described_class.deal deal).to eq([expectedSHand, expectedWHand, expectedNHand, expectedEHand])
      end
    end
    context 'with W first' do
      let(:deal) { 'W:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85' }
      it 'returns the same game with the hands rotated counterclockwise once' do
        expect(described_class.deal deal).to eq([expectedWHand, expectedNHand, expectedEHand, expectedSHand])
      end
    end
    context 'with hyphens for some hands' do
      let(:deal) { 'N:- A8654.KQ5.T.QJT6 - KQT2.AT.J6542.85' }
      it 'returns nils for hands not specified' do
        expect(described_class.deal deal).to eq([nil, expectedEHand, nil, expectedWHand])
      end
    end
  end

  THREE_TEST_RECORDS_FILE = 'spec/resource/three_test_records.pbn'
  EMPTY_LINE_IN_COMMENT_FILE = 'spec/resource/test_record_with_empty_line_in_comment.pbn'
  SINGLE_CURLY_COMMENT_FILE = 'spec/resource/test_record_with_single_line_curly_comment.pbn'
  LOTS_OF_CURLIES_FILE = 'spec/resource/test_record_with_single_line_curly_comment.pbn'
  ESCAPE_IN_COMMENT_FILE = 'spec/resource/test_record_with_escape_in_comment.pbn'
  describe '.each_game' do
    context 'with three valid test records and no multiline comments' do
      it 'passes a total of three games to the given block' do
        expect do |block|
          described_class.each_game_string(File.open(THREE_TEST_RECORDS_FILE), &block)
        end.to yield_control.exactly(3).times
      end
      subject(:games) do
        result = []
        described_class.each_game_string(File.open(THREE_TEST_RECORDS_FILE)) { |game| result << game }
        result
      end
      it 'discards all escaped lines' do
        games.each {|game| game.each_line {|line| expect(line).not_to match(/^%/)}}
      end
      it 'has the first line of the first game' do
        first_line = nil
        games[0].each_line { |line| first_line = line; break }
        expect(first_line).to eq("[Event \"\"]\n")
      end
      it 'has the last line of the first game' do
        last_line = nil
        games[0].each_line { |line| last_line = line }
        expect(last_line).to eq("W  C  0\n")
      end
      it 'has the first line of the last game' do
        first_line = nil
        games[2].each_line { |line| first_line = line; break }
        expect(first_line).to eq("[Event \"\"]\n")
      end
      it 'has the last line of the last game' do
        last_line = nil
        games[2].each_line { |line| last_line = line }
        expect(last_line).to eq("W  C 11\n")
      end
    end
    context 'with one valid test records a multiline comment containing empty lines' do
      it 'passes exactly one game to the given block' do
        expect do |block|
          described_class.each_game_string(File.open(EMPTY_LINE_IN_COMMENT_FILE), &block)
        end.to yield_control.once
      end
      context 'with two valid test records, yet one with a single-line curly-comment' do
        it 'passes two games to the given block' do
          expect do |block|
            described_class.each_game_string(File.open(SINGLE_CURLY_COMMENT_FILE), &block)
          end.to yield_control.exactly(2).times
        end
      end
      context 'with two valid test records, yet with lots of curlies for good measure' do
        it 'passes two games to the given block' do
          expect do |block|
            described_class.each_game_string(File.open(LOTS_OF_CURLIES_FILE), &block)
          end.to yield_control.exactly(2).times
        end
      end
      context 'within a comment, an escape character' do
        it 'does not consider the escape character to actually-escape' do
          expect do |block|
            described_class.each_game_string(File.open(ESCAPE_IN_COMMENT_FILE), &block)
          end.to yield_with_args("[Event \"\"]\n{\n%\n}")
        end
      end
    end
  end
end
