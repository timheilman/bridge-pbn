#todo: fix this; eliminate usage of frowned-upon autoload; make dependencies explicit and just-in-time?

module PortableBridgeNotation
  autoload :Importer, File.expand_path('../portable_bridge_notation/importer', __FILE__)
  module GameParserStates
    autoload :BeforeFirstTag, File.expand_path('../portable_bridge_notation/game_parser_states/before_first_tag', __FILE__)
    autoload :InSemicolonComment, File.expand_path('../portable_bridge_notation/game_parser_states/in_semicolon_comment', __FILE__)
    autoload :InCurlyComment, File.expand_path('../portable_bridge_notation/game_parser_states/in_curly_comment', __FILE__)
    autoload :BeforeTagName, File.expand_path('../portable_bridge_notation/game_parser_states/before_tag_name', __FILE__)
    autoload :InTagName, File.expand_path('../portable_bridge_notation/game_parser_states/in_tag_name', __FILE__)
    autoload :BeforeTagValue, File.expand_path('../portable_bridge_notation/game_parser_states/before_tag_value', __FILE__)
    autoload :InString, File.expand_path('../portable_bridge_notation/game_parser_states/in_string', __FILE__)
    autoload :BeforeTagClose, File.expand_path('../portable_bridge_notation/game_parser_states/before_tag_close', __FILE__)
    autoload :BetweenTags, File.expand_path('../portable_bridge_notation/game_parser_states/between_tags', __FILE__)
    autoload :InPlaySection, File.expand_path('../portable_bridge_notation/game_parser_states/in_play_section', __FILE__)
    autoload :InAuctionSection, File.expand_path('../portable_bridge_notation/game_parser_states/in_auction_section', __FILE__)
    autoload :InSupplementalSection, File.expand_path('../portable_bridge_notation/game_parser_states/in_supplemental_section', __FILE__)
  end
  module SubgameParsers
    autoload :DealSubgameParser, File.expand_path('../portable_bridge_notation/subgame_parsers/deal_subgame_parser', __FILE__)
  end
end
