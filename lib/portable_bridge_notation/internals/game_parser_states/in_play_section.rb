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
        end

        def tag_value=(new_value)
          @direction_order = order_for_direction new_value
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
          observer.with_play(PortableBridgeNotation::Api::Play.new(@tricks, @is_completed))
          observer.with_play_comments(@comments)
        end

        def with_special_section_token(card_string)
          if @direction_index > 3 || @tricks.empty?
            @direction_index = 0
            @tricks << { n: nil, e: nil, s: nil, w: nil }
          end

          add_new_card card_string unless card_string == hyphen
          @direction_index += 1
        end

        def add_new_card(card_string)
          new_annotated_play = Api::AnnotatedPlay.new(card_string, nil, [])
          current_direction = @direction_order[@direction_index]
          @tricks.last[current_direction] = new_annotated_play
          @comment_array_for_last_token = new_annotated_play.comments
          @annotation_steward = PlayAnnotationSteward.new(play: new_annotated_play,
                                                          trick_index: @tricks.length - 1,
                                                          direction: current_direction,
                                                          game_parser: game_parser,
                                                          special_section: self)
        end
      end
    end
  end
end
