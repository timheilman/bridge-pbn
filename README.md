# Portable Bridge Notation in Pure Ruby

### Origin of the standard

This project aims to provide parsing and building capabilities for
 [Portable Bridge Notation](http://www.tistis.nl/pbn/). The PBN version
 targeted is 2.1

### Imagined Use

The imagined use is either in a DOM-like approach via the procedural
data structure Api::Game, instances of which
are yielded from Api::Importer#import, or in
a SAX-like approach by registering objects with
Api::Importer#attach which respond_to messages such
as with_dealt_card(direction:, rank:, suit:) made from the subgame
parsers.

### Structure of the code

The primary design goal of the code base is practice with elements from
_Design Patterns_, _Clean Code_, _The Clean Coder_, _Refactoring_,
and _The Pragmatic Programmer_ .  The structure of the parsing code is
in three stages:

1. Parsing of an Io into game strings
2. Parsing of a game string into Subgames, which are:
  * start-of-game comments (only potentially populated for the first
    game string in an Io)
  * the tag pair
  * commentary following the tag pair
  * the section (if any)
3. Parsing of the subgames with a subgame parser selected based upon
   that subgame's tag name, into a Game structure (for DOM-style) or
   directly into the domain objects desired by the
   client (with client-supplied event listeners, for SAX-style).

By happy coincidence, tag names abide by
exactly the same naming convention as Ruby classes, and as such the
lookup of subgame parsers is done by looking for a class named
the same as the tag name, suffixed with "SubgameParser".

Thus the example message with_card_dealt(direction:, rank:, suit:) is
controlled by the subgame parser for the corresponding tag name, "Deal":
deal_subgame_parser.rb .

Though Play and Auction sections aren't yet implemented, I'm trying to
keep the option open that Play and Auction section parsers may
already-know following referent Note tag values while their sections are
being parsed.  This is to simplify the structure of
Game#\<auction|play\>#annotated_\<calls|plays\> so that notes
don't need de- and re-referencing.  This deliberately imposes
the cost that identical note references to be attached to multiple
calls or plays must be supplied identically to all calls or plays to
which they apply.

The inverse of parsing: building, is imagined in a corresponding
Exporter class, but is not yet approached.

### Metaprogramming Warnings and Explanation

* in Internals::ObserverBroadcaster via method_missing and respond_to?,
in order to accomplish the listening for client objects provided via
Api::Importer#attach.
* in Api::Game#initialize, in order to provide optional comment arrays
after every tag by suffixing the snake-cased tag name with "_comments"
* in Internals::ConcreteFactory, via const_get
 * depending on the require_relatives there to ensure all subgame parser
classes are defined in the proper namespace and align to tag names
suffixed with "SubgameParser"
 * depending on the require_relatives there to allow game parser states
 to refer to one another by Ruby symbol

Otherwise the message passing chain is non-meta Ruby everywhere, for
clarity.