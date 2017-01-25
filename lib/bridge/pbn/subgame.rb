module Bridge
  module Pbn
    # terminology from http://www.tistis.nl/pbn/
    # targeting PBN version 2.1

    # Note that section is provided as an unprocessed string since when tagPair's first element
    # is Auction or Play, semicolon-based comments are permitted at specified points within
    # the section, thus requiring newlines to remain in the section at this level of abstraction
    # so that those comments can be parsed in a Tag-dependent manner at the next level of abstraction
    class Subgame < Struct.new(:beginningComments, :tagPair, :followingComments, :section)
      def to_s
        return 'bc: ' + @beginningComments.join('|') +
            ' tp: ' + @tagPair.join('|') +
            ' fc: ' + @followingComments.join('|') +
            ' s: `' + section + '\''
      end
    end
  end
end