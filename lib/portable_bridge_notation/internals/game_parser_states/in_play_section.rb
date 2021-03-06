require_relative 'special_section'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InPlaySection < SpecialSection
        def post_initialize
          super
          game_parser.reached_play_section self
          @tricks = []
          @direction_index = 0
          @unnoticed_revoke = false
          @accepted_lead_out_of_turn = false
        end

        attr_reader :tricks
        attr_accessor :direction_order
        attr_accessor :direction_index
        attr_accessor :unnoticed_revoke
        attr_accessor :accepted_lead_out_of_turn

        def tag_value=(new_value)
          self.direction_order = order_for_direction new_value
        end

        def order_for_direction(direction)
          order = [:n, :e, :s, :w]
          order.rotate!(order.index(direction.downcase.to_sym))
          order
        end

        def special_section_token_char
          card_char
        end

        def raise_error(char)
          err_str = "Unexpected character within a play section: `#{char}'"
          game_parser.raise_error err_str
        end

        def start_special_section(char)
          injector.game_parser_state(:InCard, self).process_char char
        end

        def finalize_after_note_references
          observer.with_play(PortableBridgeNotation::Api::Play.new(tricks, is_completed))
          observer.with_play_comments(comments)
        end

        def with_special_section_token(card_string)
          if direction_index > 3 || tricks.empty?
            self.direction_index = 0
            tricks << { n: nil, e: nil, s: nil, w: nil }
          end

          add_new_card card_string unless card_string == hyphen
          self.direction_index = direction_index + 1
        end

        def add_new_card(card_string)
          new_annotated_play = Api::AnnotatedPlay.new(card_string, nil, revoke_get_and_reset, lead_get_and_reset, [])
          current_direction = direction_order[direction_index]
          tricks.last[current_direction] = new_annotated_play
          self.comment_array_for_last_token = new_annotated_play.comments
          self.annotation_steward = PlayAnnotationSteward.new(play: new_annotated_play,
                                                              trick_index: tricks.length - 1,
                                                              direction: current_direction,
                                                              game_parser: game_parser,
                                                              special_section: self)
        end

        def with_play_note(trick_index, direction, text)
          tricks[trick_index][direction].annotation.note = text
        end

        def with_revoke_irregularity
          self.unnoticed_revoke = true
        end

        def with_lead_irregularity
          self.accepted_lead_out_of_turn = true
        end

        def revoke_get_and_reset
          to_return = unnoticed_revoke
          self.unnoticed_revoke = false
          to_return
        end

        def lead_get_and_reset
          to_return = accepted_lead_out_of_turn
          self.accepted_lead_out_of_turn = false
          to_return
        end
      end
    end
  end
end
