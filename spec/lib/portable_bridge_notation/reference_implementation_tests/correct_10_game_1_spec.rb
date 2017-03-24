module PortableBridgeNotation
  module ReferenceImplementationTests
    RSpec.describe Api::Importer do
      describe '#import' do
        let(:described_object) { described_class.create(io: pbn_game_string) }
        context 'game 1' do
          let(:pbn_game_string) do
            StringIO.new(<<-eos)
% ==================== game 1 ====================
%
% The intention of this pbn file is to check the PBN verifier.
% The games show the possible usage of the PBN standard.
% The file does not contain errors against the PBN standard 1.0 .
%
% A simple game; with demo rest-of-line comments
%
[Event "International Amsterdam Airport Schiphol Bridgetournament"]
[Site "Amsterdam, The Netherlands NLD"]  ; rest-of-line IDENT
[Date "1995.06.10"]
[Board "1"]
[West "Podgor"]
[North "Westra"]
[East "Kalish"]
[South "Leufkens"]
[Dealer "N"]
[Vulnerable "None"]
[Deal "N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85"]
[Declarer "S"]
[Contract "5HX"]
[Result "9"]
{
                S
                H 6 3
                D A K Q 9 8 7
                C A 9 7 3 2
S K Q 10 2                      S A 8 6 5 4
H A 10                          H K Q 5
D J 6 5 4 2                     D 10
C 8 5                           C Q J 10 6
                S J 9 7 3
                H J 9 8 7 4 2
                D 3
                C K 4
}
[Auction "N"]
1D      1S 3H =1= 4S  ; end-of-line AUCTION
4NT =2= X  Pass   Pass
5C      X  5H     X
AP
[Note "1: non-forcing 6-9 points, 6-card"]
[Note "2: two colors: clubs and diamonds"]
[Play "W"]
SK H3 S4 S3     ; end-of-line PLAY
C5 C2 C6 CK
S2 H6 S5 S7
C8 CA CT C4
D2 DA DT D3
D4 DK H5 H7
-  -  -  H2
*

            eos
          end
          it 'should successfully import the sample string into Ruby-native structures' do
            game_enumerator = described_object.import
            game = game_enumerator.next
            expect { game_enumerator.next }.to raise_error(StopIteration)
            expect(game.event).to eq 'International Amsterdam Airport Schiphol Bridgetournament'
            expect(game.site).to eq 'Amsterdam, The Netherlands NLD'
            expect(game.site_comments).to eq [' rest-of-line IDENT']
            expect(game.date.year).to eq '1995'
            expect(game.date.month).to eq '06'
            expect(game.date.day).to eq '10'
            expect(game.board).to eq 1
            expect(game.west).to eq 'Podgor'
            expect(game.north).to eq 'Westra'
            expect(game.east).to eq 'Kalish'
            expect(game.south).to eq 'Leufkens'
            expect(game.dealer).to eq 'N'
            expect(game.vulnerable).to eq 'None'
            expected_deal = { n: { s: '', h: '63', d: 'AKQ987', c: 'A9732' },
                              e: { s: 'A8654', h: 'KQ5', d: 'T', c: 'QJT6' },
                              s: { s: 'J973', h: 'J98742', d: '3', c: 'K4' },
                              w: { s: 'KQT2', h: 'AT', d: 'J6542', c: '85' } }
            expect(game.deal).to eq expected_deal
            expect(game.declarer.direction).to eq 'S'
            expect(game.declarer.dummy_and_declarer_are_swapped).to eq false
            expect(game.contract).to eq '5HX'
            expect(game.result).to eq '9'
            expect(game.result_comments).to eq [] << <<-eos

                S
                H 6 3
                D A K Q 9 8 7
                C A 9 7 3 2
S K Q 10 2                      S A 8 6 5 4
H A 10                          H K Q 5
D J 6 5 4 2                     D 10
C 8 5                           C Q J 10 6
                S J 9 7 3
                H J 9 8 7 4 2
                D 3
                C K 4
            eos
            %w(1D 1S 3H 4S 4NT X Pass Pass 5C X 5H X).each_with_index do |call, call_idx|
              expect(game.auction.annotated_calls[call_idx].call).to eq call
            end
            expect(game.auction.annotated_calls[2].annotation.note).to eq ' non-forcing 6-9 points, 6-card'
            expect(game.auction.annotated_calls[3].comments[0]).to eq ' end-of-line AUCTION'
            expect(game.auction.annotated_calls[4].annotation.note).to eq ' two colors: clubs and diamonds'
            expect(game.auction.is_completed).to eq true
            [%w(SK H3 S4 S3),
             %w(C5 C2 C6 CK),
             %w(S2 H6 S5 S7),
             %w(C8 CA CT C4),
             %w(D2 DA DT D3),
             %w(D4 DK H5 H7)].each_with_index do |expected_cards_for_round, round|
              %i(w n e s).each_with_index do |dir, dir_idx|
                expect(game.play.tricks[round][dir].card).to eq expected_cards_for_round[dir_idx]
              end
            end
            expect(game.play.tricks[6][:s].card).to eq 'H2'
            expect(game.play.tricks[0][:s].comments[0]).to eq ' end-of-line PLAY'
            expect(game.play.is_completed).to eq true
          end
        end
      end
    end
  end
end
