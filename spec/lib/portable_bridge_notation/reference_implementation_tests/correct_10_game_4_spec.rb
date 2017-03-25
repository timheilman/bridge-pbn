module PortableBridgeNotation
  module ReferenceImplementationTests
    RSpec.describe Api::Importer do
      describe '#import' do
        let(:described_object) { described_class.create(io: pbn_game_string) }
        let(:pbn_game_string) do
          new_string = <<-eos
% ==================== game 4 ====================
% Games without deal; tests ISO 8859/1 characters; various tag values
%
[South "   ¡ ¢ £ ¤ ¥ ¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿"]
[West  " À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß"]
[North " à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ"]
[East  "\\\\\\"\\\\\\"\\"\\\\  \\a"]
[Result         "EW 4 NS 9"]
[Annotator      "Annotator"]
[AnnotatorNA    "AnnotatorNA"]
[BidSystemEW    "BidSystemEW"]
[BidSystemNS    "BidSystemNS"]
[Board          "13"]
[Competition    "Chicago"]
[Description    "Description"]
[EastNA         "EastNA"]
[EastType       "human"]
[EventDate      "1997.10.12"]
[EventSponsor   "EventSponsor"]
[FrenchMP       "No"]
[Generator      "by hand"]
[Hidden         "W"]
[HomeTeam       "NL"]
[Mode           "EMB"]
[NorthNA        "NorthNA"]
[NorthType      "human"]
[Room           "Open"]
[Round          "1.A.2"]
[ScoreRubber    "300/40"]
[Scoring        "Chicago"]
[Section        "Section"]
[SouthNA        "SouthNA"]
[SouthType      "human"]
[Stage          "Stage"]
[Table          "1"]
[Termination    "unterminated"]
[Time           "23:59:59"]
[TimeCall       "10"]
[TimeCard       "10"]
[TimeControl    "4/30"]
[UTCDate        "2000.01.01"]
[UTCTime        "23:59:59"]
[VisitTeam      "USA"]
[Vulnerable     "-"]
[WestNA         "WestNA"]
[WestType       "human"]
          eos
          new_string.encode!(Encoding::ISO_8859_1)
          StringIO.new(new_string)
        end
        it 'should successfully import reference implementation correct 1.0 game 4 into Ruby-native structures' do
          game_enumerator = described_object.import
          game = game_enumerator.next
          expect { game_enumerator.next }.to raise_error(StopIteration)
          expect(game.south).to eq '   ¡ ¢ £ ¤ ¥ ¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿'
          expect(game.west).to eq ' À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß'
          expect(game.north).to eq ' à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ'
          expect(game.east).to eq '\\"\\""\\  \a'
          expect(game.annotator).to eq 'Annotator'
          expect(game.annotator_na).to eq 'AnnotatorNA'
          expect(game.bid_system_ew).to eq 'BidSystemEW'
          expect(game.bid_system_ns).to eq 'BidSystemNS'
          expect(game.board).to eq 13
          expect(game.competition).to eq 'Chicago'
          expect(game.description).to eq 'Description'
          expect(game.east_na).to eq 'EastNA'
          expect(game.east_type).to eq 'human'
          expect(game.event_date.year).to eq '1997'
          expect(game.event_date.month).to eq '10'
          expect(game.event_date.day).to eq '12'
          expect(game.event_sponsor).to eq 'EventSponsor'
          expect(game.french_mp).to eq 'No'
          expect(game.generator).to eq 'by hand'
          expect(game.hidden).to eq 'W'
          expect(game.home_team).to eq 'NL'
          expect(game.mode).to eq 'EMB'
          expect(game.north_na).to eq 'NorthNA'
          expect(game.north_type).to eq 'human'
          expect(game.room).to eq 'Open'
          expect(game.round).to eq '1.A.2'
          expect(game.score_rubber).to eq '300/40'
          expect(game.scoring).to eq 'Chicago'
          expect(game.section).to eq 'Section'
          expect(game.south_na).to eq 'SouthNA'
          expect(game.south_type).to eq 'human'
          expect(game.stage).to eq 'Stage'
          expect(game.table).to eq '1'
          expect(game.termination).to eq 'unterminated'
          expect(game.time.hours).to eq 23
          expect(game.time.minutes).to eq 59
          expect(game.time.seconds).to eq 59
          expect(game.time_call).to eq 10
          expect(game.time_control).to eq '4/30'
          expect(game.utc_date.year).to eq '2000'
          expect(game.utc_date.month).to eq '01'
          expect(game.utc_date.day).to eq '01'
          expect(game.utc_time.hours).to eq 23
          expect(game.utc_time.minutes).to eq 59
          expect(game.utc_time.seconds).to eq 59
          expect(game.visit_team).to eq 'USA'
          expect(game.vulnerable).to eq 'None'
          expect(game.west_na).to eq 'WestNA'
          expect(game.west_type).to eq 'human'
        end
      end
    end
  end
end
