# Portable Bridge Notation in Pure Ruby

This project aims to provide parsing and building capabilities for
 [Portable Bridge Notation] (http://www.tistis.nl/pbn/)

The PBN version targeted is 2.1

The imagined use is as demonstrated in [bridge-stats]
 (https://github.com/timheilman/bridge-stats),
by registering objects with a PortableBridgeNotation::Importer#attach
which respond_to messages such as
with_dealt_card(direction:, rank:, suit:).  The Importer client code
can then depend both upon bridge domain classes
and PortableBridgeNotation::Importer.

There is metaprogramming here, exclusively in the Importer class, and
via method_missing and respond_to?, in order to accomplish the listening
for client objects provided via PortableBridgeNotation::Importer#attach
. Otherwise the message passing chain is pure Ruby everywhere, for
clarity.

The structure of the parsing code is in three stages, for readability
of the code:

1. Parsing of an Io into games
2. Parsing of a game into subgames, which are:
  * start-of-game comments (only potentially populated for the first
    game in an io)
  * the tag pair
  * commentary following the tag pair
  * the section (if any)
3. Parsing of the subgames with a subgame parser selected based upon
   that subgame's tag name, into the domain objects desired by the
   client.

One other oddity is that by happy coincidence, tag names abide by
exactly the same naming convention as Ruby classes, and as such the
lookup of subgame parsers is done by looking for a class named
the same as the tag name, suffixed with "SubgameParser".

Thus the example message with_card_dealt(direction:, rank:, suit:) is
controlled by the subgame parser for the corresponding tag name, "Deal":
deal_subgame_parser.rb .

Though Play and Auction sections aren't yet implemented, I'm trying to
keep the option open that Play and Auction section parsers may
already-know following referent Note tag values while their sections are
being parsed.  This is to simplify the required implementation from
consumers: #with_auction_note alone, rather than #with_auction_note_ref
AND #with_auction_note_ref_resolution.

The structure also hopefully provides easy conceptual buckets to keep
the concerns of the parsing separated and each class narrowly focused in
obvious ways.

The inverse of parsing: building, is imagined in a corresponding
Exporter class, but is not yet approached.
