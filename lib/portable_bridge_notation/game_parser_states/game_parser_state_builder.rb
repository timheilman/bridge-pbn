require_relative 'game_parser_state'
require_relative 'outside_tag_and_section_template'
require_relative 'before_first_tag'
require_relative 'before_tag_name'
require_relative 'in_tag_name'
require_relative 'before_tag_value'
require_relative 'in_string'
require_relative 'before_tag_close'
require_relative 'between_tags'
require_relative 'in_curly_comment'
require_relative 'in_semicolon_comment'
require_relative 'in_auction_section'
require_relative 'in_play_section'
require_relative 'in_supplemental_section'
class PortableBridgeNotation::GameParserStates::GameParserStateBuilder
  attr_reader :game_parser
  attr_reader :domain_builder
  attr_reader :game_parser_state_factory
  attr_reader :next_state
  def with_game_parser(game_parser)
    @game_parser = game_parser
    self
  end
  def with_domain_builder(domain_builder)
    @domain_builder = domain_builder
    self
  end
  def with_game_parser_state_factory(state_factory)
    @game_parser_state_factory = state_factory
    self
  end
  def with_next_state(next_state)
    @next_state = next_state
    self
  end
  def build(class_sym)
    PortableBridgeNotation::GameParserStates.const_get(class_sym).new(self)
  end
end