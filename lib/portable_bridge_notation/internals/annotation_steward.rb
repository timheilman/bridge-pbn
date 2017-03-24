module PortableBridgeNotation
  module Internals
    class AnnotationSteward
      def initialize(annotatable:, game_parser:, special_section:)
        @annotatable = annotatable
        @game_parser = game_parser
        @special_section = special_section
      end

      def with_suffix_annotation(suffix_annotation_string)
        with_nag(nag_string_for_suffix_annotation_string(suffix_annotation_string))
      end

      def nag_string_for_suffix_annotation_string(suffix_annotation_string)
        unless suffix_nag_indexes.include? suffix_annotation_string
          @game_parser.raise_error "Unexpected suffix annotation string #{suffix_annotation_string}"
        end
        suffix_nag_indexes[suffix_annotation_string]
      end

      def with_nag(nag_string)
        annotation = make_or_get_annotation
        annotation.commented_numeric_annotation_glyphs <<
          Api::CommentedNumericAnnotationGlyph.new(Integer(nag_string), [])
        annotation.commented_numeric_annotation_glyphs.last.comments
      end

      def make_or_get_annotation
        @annotatable.annotation = Api::Annotation.new(nil, [], [], []) if @annotatable.annotation.nil?
        @annotatable.annotation
      end
    end
    class AuctionAnnotationSteward < AnnotationSteward
      def initialize(call:, game_parser:, special_section:, call_index:)
        super annotatable: call, game_parser: game_parser, special_section: special_section
        @call_index = call_index
      end

      def suffix_nag_indexes
        { '!' => 1, '?' => 2, '!!' => 3, '??' => 4, '!?' => 5, '?!' => 6 }
      end

      def with_note_reference_number(note_reference_number)
        annotation = make_or_get_annotation
        @game_parser.expect_auction_ref_resolution(@special_section, @call_index, note_reference_number)
        annotation.note_comments
      end
    end
    class PlayAnnotationSteward < AnnotationSteward
      def initialize(play:, game_parser:, special_section:, trick_index:, direction:)
        super annotatable: play, game_parser: game_parser, special_section: special_section
        @trick_index = trick_index
        @direction = direction
      end

      def suffix_nag_indexes
        { '!' => 7, '?' => 8, '!!' => 9, '??' => 10, '!?' => 11, '?!' => 12 }
      end

      def with_note_reference_number(note_reference_number)
        annotation = make_or_get_annotation
        @game_parser.expect_play_ref_resolution(@special_section, @trick_index, @direction, note_reference_number)
        annotation.note_comments
      end
    end
  end
end
