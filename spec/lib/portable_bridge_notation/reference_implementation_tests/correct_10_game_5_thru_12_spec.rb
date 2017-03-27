module PortableBridgeNotation
  module ReferenceImplementationTests
    RSpec.describe Api::Importer, group: :ref_impl_tests do
      describe '#import game 5-12 (different scoring systems)' do
        let(:described_object) { described_class.create(io: pbn_game_string) }
        context('game 5') do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 5 ====================
[Result         "EW 4"]
[Competition    "Individuals"]
[EastType       "program"]
[FrenchMP       "Yes"]
[Hidden         "N"]
[Mode           "IBS"]
[NorthType      "program"]
[Room           "Closed"]
[ScoreIMP       "EW 10 NS 0"]
[Scoring        "IMP_1948"]
[SouthType      "program"]
[Vulnerable     "All"]
[WestType       "program"]
            eos
          end
          it 'should import IMP_1948 scoring' do
            game = import_only_game
            expect(game.result).to eq 'EW 4'
            expect(game.competition).to eq 'Individuals'
            expect(game.east_type).to eq 'program'
            expect(game.french_mp).to eq 'Yes'
            expect(game.hidden).to eq 'N'
            expect(game.mode).to eq 'IBS'
            expect(game.north_type).to eq 'program'
            expect(game.room).to eq 'Closed'
            expect(game.score_imp).to eq 'EW 10 NS 0'
            expect(game.scoring).to eq 'IMP_1948'
            expect(game.south_type).to eq 'program'
            expect(game.vulnerable).to eq 'All'
            expect(game.west_type).to eq 'program'
          end
        end
        context 'game 6' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 6 ====================
[Result         "NS 9"]
[Competition    "Pairs"]
[Hidden         "E"]
[Mode           "OKB"]
[ScoreIMP       "NS 10"]
[Scoring        "EMP"]
[Vulnerable     "All"]
            eos
          end
          it 'should import EMP scoring' do
            game = import_only_game
            expect(game.result).to eq 'NS 9'
            expect(game.competition).to eq 'Pairs'
            expect(game.hidden).to eq 'E'
            expect(game.mode).to eq 'OKB'
            expect(game.score_imp).to eq 'NS 10'
            expect(game.scoring).to eq 'EMP'
            expect(game.vulnerable).to eq 'All'
          end
        end
        context 'game 7' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 7 ====================
[Competition    "Teams"]
[Hidden         "S"]
[Mode           "TABLE"]
[ScoreRubber    "EW 300/40"]
[Scoring        "Rubber"]
[Vulnerable     "Both"]
            eos
          end
          it 'should import Rubber scoring' do
            game = import_only_game
            expect(game.competition).to eq 'Teams'
            expect(game.hidden).to eq 'S'
            expect(game.mode).to eq 'TABLE'
            expect(game.score_rubber).to eq 'EW 300/40'
            expect(game.scoring).to eq 'Rubber'
            expect(game.vulnerable).to eq 'All'
          end
        end
        context 'game 8' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 8 ====================
[Competition    "Rubber"]
[Hidden         "EWNS"]
[Mode           "TC"]
[ScoreIMP       "NS 10 EW 0"]
[Scoring        "IMP_1961"]
[Vulnerable     "NS"]
          eos
          end
          it 'should import IMP_1961 scoring' do
            game = import_only_game
            expect(game.competition).to eq 'Rubber'
            expect(game.hidden).to eq 'EWNS'
            expect(game.mode).to eq 'TC'
            expect(game.score_imp).to eq 'NS 10 EW 0'
            expect(game.scoring).to eq 'IMP_1961'
            expect(game.vulnerable).to eq 'NS'
          end
        end
        context 'game 9' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 9 ====================
[ScoreIMP       "10"]
[Scoring        "IMP"]
[Vulnerable     "EW"]
          eos
          end
          it 'should import IMP scoring' do
            game = import_only_game
            expect(game.score_imp).to eq '10'
            expect(game.scoring).to eq 'IMP'
            expect(game.vulnerable).to eq 'EW'
          end
        end
        context 'game 10' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 10 ====================
[Score          "-1000"]
[Scoring        "OldMP"]
          eos
          end
          it 'should import OldMP scoring' do
            game = import_only_game
            expect(game.score).to eq '-1000'
            expect(game.scoring).to eq 'OldMP'
          end
        end
        context 'game 11' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 11 ====================
[ScoreIMP       "EW -2.5"]
[Scoring        "BAM"]
          eos
          end
          it 'should import BAM scoring' do
            game = import_only_game
            expect(game.score_imp).to eq 'EW -2.5'
            expect(game.scoring).to eq 'BAM'
          end
        end
        context 'game 12' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 12 ====================
[ScoreRubber    "EW 300/40 NS 50 / 70  "]
[Scoring        "Rubber"]
          eos
          end
          it 'should import Rubber scoring with trailing spaces in ScoreRubber' do
            game = import_only_game
            expect(game.score_rubber).to eq 'EW 300/40 NS 50 / 70  '
            expect(game.scoring).to eq 'Rubber'
          end
        end
      end
    end
  end
end
