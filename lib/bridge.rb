module Bridge
  autoload :Game,   File.expand_path('../bridge/game',   __FILE__)
  autoload :Card,   File.expand_path('../bridge/card',   __FILE__)
  autoload :Strain, File.expand_path('../bridge/strain', __FILE__)
  autoload :Rank,   File.expand_path('../bridge/rank',   __FILE__)
  autoload :Hand,   File.expand_path('../bridge/hand',   __FILE__)
  autoload :Player, File.expand_path('../bridge/player', __FILE__)
  autoload :Handler, File.expand_path('../bridge/handler', __FILE__)
  autoload :Pbn,    File.expand_path('../bridge/pbn', __FILE__)
  autoload :PbnGameParser, File.expand_path('../bridge/pbn_game_parser', __FILE__)
  autoload :PbnSubgameMarshaller, File.expand_path('../bridge/pbn_subgame_marshaller', __FILE__)
end
