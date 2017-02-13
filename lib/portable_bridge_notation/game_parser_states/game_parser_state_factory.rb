require_relative 'game_parser_state_builder'
class PortableBridgeNotation::GameParserStates::GameParserStateFactory
  attr_reader :game_parser
  attr_reader :domain_builder

  def initialize(game_parser, domain_builder)
    @game_parser = game_parser
    @domain_builder = domain_builder
  end

  def make_state(class_sym, next_state = nil)
    game_parser_state_builder = PortableBridgeNotation::GameParserStates::GameParserStateBuilder.new
    game_parser_state_builder.
        with_game_parser(game_parser).
        with_domain_builder(domain_builder).
        with_game_parser_state_factory(self).
        with_next_state(next_state).
        build class_sym
  end
end