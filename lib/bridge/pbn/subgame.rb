module Bridge::Pbn
  # terminology from http://www.tistis.nl/pbn/
  # targeting PBN version 2.1

  # For now, section is provided as a string. Subgame parsers will be responsible for parsing sections.
  class Subgame < Struct.new(:beginningComments, :tagPair, :followingComments, :section)
    def to_s
      return 'bc: ' + beginningComments.join('|') +
          ' tp: ' + tagPair.join('|') +
          ' fc: ' + followingComments.join('|') +
          ' s: `' + section + '\''
    end
  end
end