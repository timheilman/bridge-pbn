require 'ostruct'

module PortableBridgeNotation
  module Api
    # intent: try only to bring the structures of PBN into equivalent Ruby-language structures.
    # It only accomplishes *only* the breaking-up of PBN data into shorter
    # strings themselves arranged in Ruby-native arrays and structures with descriptive field naming.
    # The meanings of all field values are still conveyed by the PBN standard.
    #
    # Symbols rather than Strings are used to implement the flyweight pattern regarding some bridge domain nomenclature.
    # The meanings of the symbols is specified by the PBN standard.  The evasion of dependency-magnetism is an explicit
    # design goal, hence no domain enumerations are specified:
    #
    # directions: :n :s :e :w
    # strains: :s :h :c :d :n_t
    #
    # Consider alternately (in a SAX vs DOM approach) supplying a listener for the events dispatched by the
    # game_parser_states with Importer#attach_observer
    MANDATORY_TAG_SET = [
      :event, # 3.4.1 descriptive string name of the event, shun abbreviations
      :site, # 3.4.2 ISO 3166 or EN 23166 recommended; "Portland, OR USA"
      :date, # 3.4.3 Ruby Struct Date described below
      :board, # 3.4.4 positive integer, board number of the deal
      :west, # 3.4.5 player name(s) as in a telephone directory "Smith, John T." or "Jones, M. N."
      :north, # 3.4.6 player name(s) as in :west
      :east, # 3.4.7 player name(s) as in :west
      :south, # 3.4.8 player name(s) as in :west
      :dealer, # 3.4.9 "N", "S", "E" or "W"
      :vulnerable, # 3.4.10 "None", "NS", "EW", "All", ("Love", "-", "Both" are disallowed; use export format)
      :deal, # 3.4.11 Ruby hash from single-char among "NSEW" to
      # (cont'd) (a hash from single-char among "CDHS" to string of distinct single-char ranks among "AKQJT98765432")

      :scoring, # 3.4.12 open-ended; see spec for examples
      :declarer, # 3.4.13 Ruby Struct Declarer described below
      :contract, # 3.4.14 "Pass" or Ruby Struct Contract described below
      :result # 3.4.15 Tricks taken are 0 .. 13 and may be space-delimited-preceded by EW or NS; defaults to declarer.
    ].freeze
    KNOWN_TAG_SET = [].push(*MANDATORY_TAG_SET).push(
      # special sections
      :auction, # 3.5 Ruby Struct Auction described
      :play, # 3.6 Ruby Struct Play described below
      # Note tags' data are stored without indirection in the actual call or play made in the Auction or Play structs.

      # 4.1 Game-related information
      :competition, # 4.1.1 Examples: "Cavendish", "Chicago", "Individuals", "Pairs", "Rubber", "Teams"
      :deal_id, # 4.1.2 must be unique among all deals
      :description, # 4.1.3 arbitrary game description
      :french_mp, # 4.1.4 'Yes' or 'No'
      :generator, # 4.1.5 name of hand generator program and potentially a seed value
      :hidden, # 4.1.6 directions of cards that should be hidden initially, string comprised of "N", "S", "E", "W"
      :room, # 4.1.7 "Open" or "Closed" for teams tournaments
      :termination, # 4.1.8 "abandoned", "adjudication", "death", "emergency", "normal", "rules infraction",
      # (cont'd) "time forfeit", and "unterminated"

      # 4.2 Score-related information
      :score, # 4.2.1 "<score>" "EW <score>" "NS <score>" "EW <score> NS <score>" "NS <score> EW <score>"; see :scoring
      :score_imp, # 4.2.2 same as :score but in international match-points
      :score_mp, # 4.2.3 same as :score but in match points; see :scoring and 'MP1'
      :score_percentage, # 4.2.4 same as :score but in percentage, 0-100
      :score_rubber, # 4.2.5 same as :score but with <over-the-line-score>/<under-the-line-score>
      :score_rubber_history, # 4.2.6 Ruby Struct; must align with :vulnerable
      :optimum_score, # 4.2.7

      # 4.3 Player-related information
      :bid_system_ew, # 4.3.1
      :bid_system_ns, # 4.3.1
      :pair_ew, # 4.3.2
      :pair_ns, # 4.3.2
      :west_na, # 4.3.3 network address or email address
      :north_na, # 4.3.3
      :east_na, # 4.3.3
      :south_na, # 4.3.3
      :west_type, # 4.3.4 "human" or "program"
      :north_type, # 4.3.4
      :east_type, # 4.3.4
      :south_type, # 4.3.4

      # 4.4 Event-related information
      :event_date, # 4.4.1
      :event_sponsor, # 4.4.2
      :home_team, # 4.4.3
      :round, # 4.4.4 must =~ /[A-Za-z0-9_.]/; period is used only to separate round indicators most-sig to least-sig
      :section, # 4.4.5
      :stage, # 4.4.6
      :table, # 4.4.7
      :visit_team, # 4.4.8

      # 4.5 Time- and Date-related information
      :time, # 4.5.1 Ruby struct described below
      :utc_date, # 4.5.2 same as :date, yet according to Universal Coordinated Time
      :utc_time, # 4.5.3 same as :time, yet according to Universal Coordinated Time

      # 4.6 Time Control-related information
      :time_control, # 4.6.1
      :time_call, # 4.6.2
      :time_card, # 4.6.3

      # 4.7 Miscellaneous information
      :annotator, # 4.7.1
      :annotator_na, # 4.7.2 network address or email address
      :application, # 4.7.3 works in concert with application_comments for external programs
      :mode, # "EM" for email, "IBS" for internet bridge server, "OKB" for OK Bridge, "TABLE" for normal table
      # (cont'd) "TC" for general telecommunication

      # 5.2 - 5.10 Specified supplemental sections (tables)
      :auction_table, # 5.3
      :auction_time_table, # 5.4
      :instant_score_table, # 5.5
      :optimum_play_table, # 5.6
      :optimum_result_table, # 5.7
      :play_time_table, # 5.8
      :score_table, # 5.9
      :total_score_table, # 5.10
    ).freeze

    ##
    # Primary data structure as interface to and from portable bridge notation
    class Game < OpenStruct
      def initialize
        super
        # intent: transformation back to PBN structure beyond string meanings will be identical
        # whether no-comments represented as nil or empty array, so avoid nil and use the empty array
        # for all outside-tag-pair-and-special-section commentary
        self.initial_comments = []
        KNOWN_TAG_SET.each do |known_tag|
          send("#{known_tag}=", nil)
          send("#{known_tag}_comments=", [])
        end
        self.supplemental_sections = {}
      end
    end

    # with year "YYYY", month "MM", day "DD"; "?" is an allowed char for any unknown digit
    Date = Struct.new(:year, :month, :day)

    # local time for :site, 24-hour clock
    Time = Struct.new(:hours, :minutes, :seconds)

    # "N", "S", "E" or "W" for direction
    Declarer = Struct.new(:direction, :dummy_and_declarer_are_swapped)

    # :level integer 1-7
    # :strain string "C" "D" "H" "S" "NT"
    # :risk string "", "X", "XX"
    Contract = Struct.new(:level, :strain, :risk)

    # :declarer and :contract must agree with this section if :is_completed
    Auction = Struct.new(:annotated_calls, :is_completed)

    # :result must agree with this section if :is_completed
    # :tricks is an array of hashes from directions nesw to hashes from suits cdhs to AnnotatedPlays
    Play = Struct.new(:tricks, :is_completed)

    # Section 3.5 and 3.5.1
    # :call may be "AP", "Pass", "X", "XX", "<k><strain>", "-" (it is not yet this player's turn)
    AnnotatedCall = Struct.new(:call,
                               :annotation,
                               :is_insufficient_but_accepted,
                               :skipped_player_count, # due to accepted out-of-rotation call
                               :comments)

    # Section 3.6 and 3.6.1
    # :card may be "-" when it doesn't matter, or "<suit><rank>" among "SHDC" and "AKQJT98765432"
    AnnotatedPlay = Struct.new(:card,
                               :annotation,
                               :is_unnoticed_revoke,
                               :is_accepted_noninitial_lead_out_of_turn,
                               :comments)

    # Section 3.5.2 and 3.6.2
    # for suffix annotations, use NAG 1-6 for auction, 7-12 for play
    # :note optional annotation note string
    # :commented_numeric_annotation_glyphs array
    Annotation = Struct.new(:note,
                            :note_comments,
                            :commented_numeric_annotation_glyphs)

    # :numeric_annotation_glyph
    # 0 => no annotation
    # 1 - 12 => replacements for suffix annotations
    # suffix annotation ! good call/card is 1 for auction, 7 for play
    # suffix annotation ? poor call/card is 2 for auction, 8 for play
    # suffix annotation !! very good call/card is 3 for auction, 9 for play
    # suffix annotation ?? very poor call/card is 4 for auction, 10 for play
    # suffix annotation !? speculative call/card is 5 for auction, 11 for play
    # suffix annotation ?! questionable call/card is 6 for auction, 12 for play
    # 13 => call has been corrected manually
    # 14 => card has been corrected manually
    # 15-255 => commenting calls and played cards
    CommentedNumericAnnotationGlyph = Struct.new(:numeric_annotation_glyph, :comments)

    # For unrecognized supplemental tags/sections
    SupplementalSection = Struct.new(:tag_value, :section_string, :comments)
  end
end
