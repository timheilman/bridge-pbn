require_relative 'game_parser_state_mediator'

class PortableBridgeNotation::GameParserStates::GameParserStateMediatorBuilder
  attr_reader :game_parser
  attr_reader :subgame_builder
  attr_reader :game_parser_state_factory
  attr_reader :next_state
  def with_game_parser(game_parser)
    @game_parser = game_parser
    self
  end
  def with_subgame_builder(subgame_builder)
    @subgame_builder = subgame_builder
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
  def build
    return PortableBridgeNotation::GameParserStates::GameParserStateMediator.new(self)
  end
end