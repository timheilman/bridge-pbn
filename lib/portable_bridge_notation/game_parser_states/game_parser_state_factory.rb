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
class PortableBridgeNotation::GameParserStates::GameParserStateFactory
  attr_reader :parser
  attr_reader :domain_builder
  def initialize(parser, domain_builder)
    @parser = parser
    @domain_builder = domain_builder
  end
  def make_state(class_sym, next_state = nil)
    PortableBridgeNotation::GameParserStates.const_get(class_sym).new(parser, domain_builder, self, next_state)
  end
end