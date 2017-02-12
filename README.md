This project aims to provide parsing and building capabilities for [Portable Bridge Notation] (http://www.tistis.nl/pbn/)

The PBN version targeted is 2.1

The imagined use is as demonstrated in [bridge-stats] (https://github.com/timheilman/bridge-stats):
by providing builder object(s) to this library prepared to receive messages such as
with_dealt_card(direction:, rank:, suit:), itself with access to domain objects for whatever ruby bridge project
wishing to employ this gem for its i/o of bridge data.

The structure of the parsing code is in three stages, for readability and maintainability of the code:

1. Parsing of an Io into games
2. Parsing of a game into subgames, which are:
  * start-of-game comments (only populated for the first game in an io)
  * the tag pair
  * commentary following the tag pair
  * the section (if any)
3. Parsing of the subgame with a subgame parser selected based upon that subgame's tag name.

Thus the example message with_card_dealt(direction:, rank:, suit:) is controlled by the subgame parser for the
corresponding tag name, "Deal": deal_subgame_parser.rb .

This structure will allow Play and Auction sections to already-know following referent Note tag values while their
sections are being parsed, simplifying the required implementation from consumers: with_auction_note alone, rather than
with_auction_note_ref AND with_note_ref_resolution.  The structure also hopefully provides easy conceptual buckets
to keep the concerns of the parsing separated and each class narrowly focused, permitting a very high level of
adherence to the spec without sacrificing maintainability.

The inverse of parsing: building, is imagined but not yet approached.
