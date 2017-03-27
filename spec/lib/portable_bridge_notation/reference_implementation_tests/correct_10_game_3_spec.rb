module PortableBridgeNotation
  module ReferenceImplementationTests
    RSpec.describe Api::Importer, group: :ref_impl_tests do
      describe '#import game 3' do
        let(:described_object) { described_class.create(io: pbn_game_string) }
        let(:pbn_game_string) do
          StringIO.new(<<-eos)
% ==================== game 3 ====================
% Game with all irregularity situations
%
[Event "Test illegals"]
[Dealer "N"]
[Vulnerable "None"]
[Deal "W:KQT2.AT.J6542.85 .63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4"]
[Declarer "^S"]
[Contract "5HX"]
[Result "^5"]
[Auction "W"]
- ^S 1D ^I 1C
4S ^I 3NT ^S ^S
X 5H X AP
[Play "W"]
SK H3 S4 S3
C5 C2 ^R S5 ^L CK
S2 H6 ^R C6 S7
C8 CA CT C4
D2 DA DT D3
D4 DK H5 H7
-  -  -  H2
*
          eos
        end
        it 'should import a game with all auction and play irregularity situations' do
          game = import_only_game
          expect(game.event).to eq 'Test illegals'
          expect(game.dealer).to eq 'N'
          expect(game.vulnerable).to eq 'None'
          # identical result to game 1 but represented differently in the input string
          expected_deal = { n: { s: '', h: '63', d: 'AKQ987', c: 'A9732' },
                            e: { s: 'A8654', h: 'KQ5', d: 'T', c: 'QJT6' },
                            s: { s: 'J973', h: 'J98742', d: '3', c: 'K4' },
                            w: { s: 'KQT2', h: 'AT', d: 'J6542', c: '85' } }
          expect(game.deal).to eq expected_deal
          expect(game.declarer.direction).to eq 'S'
          expect(game.declarer.dummy_and_declarer_are_swapped).to eq true
          expect(game.contract).to eq '5HX'
          expect(game.result).to eq '^5'

          %w(1D 1C 4S 3NT X 5H X AP).each_with_index do |call, call_idx|
            expect(game.auction.annotated_calls[call_idx].call).to eq call
          end
          expect(game.auction.annotated_calls[0].skipped_player_count).to eq 1
          expect(game.auction.annotated_calls[1].is_insufficient_but_accepted).to eq true
          expect(game.auction.annotated_calls[3].is_insufficient_but_accepted).to eq true
          expect(game.auction.annotated_calls[4].skipped_player_count).to eq 2
          expect(game.auction.is_completed).to eq true

          [%w(SK H3 S4 S3),
           %w(C5 C2 S5 CK),
           %w(S2 H6 C6 S7),
           %w(C8 CA CT C4),
           %w(D2 DA DT D3),
           %w(D4 DK H5 H7)].each_with_index do |expected_cards_for_round, round|
            %i(w n e s).each_with_index do |dir, dir_idx|
              expect(game.play.tricks[round][dir].card).to eq expected_cards_for_round[dir_idx]
            end
          end
          expect(game.play.tricks[6][:s].card).to eq 'H2'
          expect(game.play.tricks[1][:e].is_unnoticed_revoke).to eq true
          expect(game.play.tricks[1][:s].is_accepted_noninitial_lead_out_of_turn).to eq true
          expect(game.play.tricks[2][:e].is_unnoticed_revoke).to eq true
          expect(game.play.is_completed).to eq true
        end
      end
    end
  end
end
