#todo: fix this; eliminate usage of frowned-upon autoload; make dependencies explicit and just-in-time?
module PortableBridgeNotation
  autoload :Handler, File.expand_path('../portable_bridge_notation/handler', __FILE__)
  autoload :SingleCharComparisonConstants, File.expand_path('../portable_bridge_notation/single_char_comparison_constants', __FILE__)
  autoload :HandStringParser, File.expand_path('../portable_bridge_notation/hand_string_parser', __FILE__)
  autoload :DealStringParser, File.expand_path('../portable_bridge_notation/deal_string_parser', __FILE__)
  autoload :IoParser, File.expand_path('../portable_bridge_notation/io_parser', __FILE__)
  autoload :ParserUtil, File.expand_path('../portable_bridge_notation/parser_util', __FILE__)
  autoload :Subgame, File.expand_path('../portable_bridge_notation/subgame', __FILE__)
  autoload :SubgameBuilder, File.expand_path('../portable_bridge_notation/subgame_builder', __FILE__)
  autoload :GameParser, File.expand_path('../portable_bridge_notation/game_parser', __FILE__)
  autoload :SubgameParserChainFactory, File.expand_path('../portable_bridge_notation/subgame_parser_chain_factory', __FILE__)
  module GameParserStates
    autoload :GameParserState, File.expand_path('../portable_bridge_notation/game_parser_states/game_parser_state', __FILE__)
    autoload :OutsideTagAndSectionTemplate, File.expand_path('../portable_bridge_notation/game_parser_states/outside_tag_and_section_template', __FILE__)
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
