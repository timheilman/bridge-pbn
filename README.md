# Portable Bridge Notation in Pure Ruby

### Origin of the standard

This project aims to provide parsing and building capabilities for
 [Portable Bridge Notation](http://www.tistis.nl/pbn/). The PBN version
 targeted is 2.1 .  Many thanks to Tis Veugen (tis.veugen :common symbol
 here: gmail.com) for the creation and maintenance of the spec and
 provision copyright-free of the reference implementation, the PBN
 Verifier, including its tests, which have been copied into this repo
 with his permission.

### Imagined Use

The imagined use is either in a DOM-like approach via the procedural
data structure Api::Game, instances of which
are yielded from Api::Importer#import, or in
a SAX-like approach by registering objects with
Api::Importer#attach which respond_to messages such
as with_dealt_card(direction:, rank:, suit:) made from the
In<TagName>Section GameParserStates.

### Structure of the code

The primary design goal of the code base is practice with elements from
_Design Patterns_, _Clean Code_, _The Clean Coder_, _Refactoring_,
and _The Pragmatic Programmer_ .  The structure of the parsing code is
in two stages:

1. Parsing of an Io into game strings, yielding those strings
2. Parsing of a game string into games, described in game.rb

By happy coincidence, tag names abide by exactly the same naming
convention as Ruby classes, and as such the lookup of
In<TagName>Section GameParserStates is done by looking for a class
constructed from its name.

Thus the example message with_card_dealt(direction:, rank:, suit:) is
controlled by the InDealSection GameParserState for the corresponding
tag name, "Deal": in_deal_section.rb .

Though Play and Auction sections aren't yet implemented, I'm trying to
keep the option open that Play and Auction section parsers may
help emit games with their Note tag values already-populated.
This is to simplify the structure of
Game#\<auction|play\>#annotated_\<calls|plays\> so that notes
don't need de- and re-referencing.  This deliberately imposes
the cost that identical note references to be attached to multiple
calls or plays must be supplied identically to all calls or plays to
which they apply.

The inverse of parsing: building, is imagined in a corresponding
Exporter class, but is not yet approached.
