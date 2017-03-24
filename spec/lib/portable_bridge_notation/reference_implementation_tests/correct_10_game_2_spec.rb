module PortableBridgeNotation
  module ReferenceImplementationTests
    RSpec.describe Api::Importer do
      describe '#import' do
        let(:described_object) { described_class.create(io: pbn_game_string) }
        let(:pbn_game_string) do
          StringIO.new(<<-eos)
% ==================== game 2 ====================
% Same game; no cards for W/E; demo (nonsense) comments
%
[Event "2 International Amsterdam Airport Schiphol Bridgetournament"]
[Site "Amsterdam, The Netherlands NLD"]
[Date "1995.06.10"]
[Board "1"]
[West "Podgor"]
[North "Westra"]
[East "Kalish"]
[South "Leufkens"]
[Dealer "N"]
[Vulnerable "Love"]
[Deal "W:- .63.AKQ987.A9732 - J973.J98742.3.K4"]
[Declarer "S"]
[Contract "5HX"]
[Result "NS 9 EW 4"]
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
[Auction "W"]
- 1D 1S 3H {A1} {A2} ! {B1} {B2} $13 {C1} {C2} =1= {D1} {D2}
4S 4NT =2= X Pass
Pass 5C X 5H
X AP
[Note "1: non-forcing 6-9 points, 6-card"]
[Note "2: two colors: clubs and diamonds"]
[Play "W"]
SK {A1} {A2} ! {B1} {B2} $14 {C1} {C2} =1= {D1} {D2} H3 S4 S3
C5 C2 C6 CK
S2 H6 S5 S7
C8 CA CT C4
D2 DA DT D3
D4 DK H5 H7
-  -  -  H2
*
[Note "1:highest of series"]
          eos
        end
        it 'should successfully import reference implementation test 2 into Ruby-native structures' do
          game_enumerator = described_object.import
          game = game_enumerator.next
          expect { game_enumerator.next }.to raise_error(StopIteration)
          expect(game.event).to eq '2 International Amsterdam Airport Schiphol Bridgetournament'
          expect(game.vulnerable).to eq 'None'
          expected_deal = { n: { s: '', h: '63', d: 'AKQ987', c: 'A9732' },
                            s: { s: 'J973', h: 'J98742', d: '3', c: 'K4' } }
          expect(game.deal).to eq expected_deal
          expect(game.result).to eq 'NS 9 EW 4'

          %w(1D 1S 3H 4S 4NT X Pass Pass 5C X 5H X).each_with_index do |call, call_idx|
            expect(game.auction.annotated_calls[call_idx].call).to eq call
          end
          expect(game.auction.annotated_calls[2].comments[0]).to eq 'A1'
          expect(game.auction.annotated_calls[2].comments[1]).to eq 'A2'
          annotation_3h = game.auction.annotated_calls[2].annotation
          expect(annotation_3h.commented_numeric_annotation_glyphs[0].numeric_annotation_glyph).to eq 1
          expect(annotation_3h.commented_numeric_annotation_glyphs[0].comments[0]).to eq 'B1'
          expect(annotation_3h.commented_numeric_annotation_glyphs[0].comments[1]).to eq 'B2'
          expect(annotation_3h.commented_numeric_annotation_glyphs[1].numeric_annotation_glyph).to eq 13
          expect(annotation_3h.commented_numeric_annotation_glyphs[1].comments[0]).to eq 'C1'
          expect(annotation_3h.commented_numeric_annotation_glyphs[1].comments[1]).to eq 'C2'
          expect(annotation_3h.note).to eq ' non-forcing 6-9 points, 6-card'
          expect(annotation_3h.note_comments[0]).to eq 'D1'
          expect(annotation_3h.note_comments[1]).to eq 'D2'
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
          # SK {A1} {A2} ! {B1} {B2} $14 {C1} {C2} =1= {D1} {D2} H3 S4 S3
          annotated_play_sk = game.play.tricks[0][:w]
          expect(annotated_play_sk.comments[0]).to eq 'A1'
          expect(annotated_play_sk.comments[1]).to eq 'A2'
          annotation_sk = annotated_play_sk.annotation
          expect(annotation_sk.commented_numeric_annotation_glyphs[0].numeric_annotation_glyph).to eq 7
          expect(annotation_sk.commented_numeric_annotation_glyphs[0].comments[0]).to eq 'B1'
          expect(annotation_sk.commented_numeric_annotation_glyphs[0].comments[1]).to eq 'B2'
          expect(annotation_sk.commented_numeric_annotation_glyphs[1].numeric_annotation_glyph).to eq 14
          expect(annotation_sk.commented_numeric_annotation_glyphs[1].comments[0]).to eq 'C1'
          expect(annotation_sk.commented_numeric_annotation_glyphs[1].comments[1]).to eq 'C2'
          expect(annotation_sk.note).to eq 'highest of series'
          expect(annotation_sk.note_comments[0]).to eq 'D1'
          expect(annotation_sk.note_comments[1]).to eq 'D2'
        end
      end
    end
  end
end
