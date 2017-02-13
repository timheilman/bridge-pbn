#todo: fix this; eliminate usage of frowned-upon autoload; make dependencies explicit and just-in-time?

module PortableBridgeNotation
  autoload :Importer, File.expand_path('../portable_bridge_notation/importer', __FILE__)
  module SubgameParsers
    autoload :DealSubgameParser, File.expand_path('../portable_bridge_notation/subgame_parsers/deal_subgame_parser', __FILE__)
  end
end
