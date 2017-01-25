require 'pry'
module Bridge
  class Rank < Struct.new(:order, :succ)
    include Comparable

    def <=>(other)
      order <=> other.order
    end

    NAME_MAP = {
      14 => 'ace',
      13 => 'king',
      12 => 'queen',
      11 => 'jack',
      10 => 'ten',
      9 => 'nine',
      8 => 'eight',
      7 => 'seven',
      6 => 'six',
      5 => 'five',
      4 => 'four',
      3 => 'three',
      2 => 'two'
    }

    @all = []
    NAME_MAP.keys.each do |order|
      @all << new(order, @all.last)
      const_set NAME_MAP[order].capitalize.to_sym, @all.last
    end

    @all = @all.map(&:freeze).freeze

    def to_s
      NAME_MAP[order]
    end

    def self.all
      @all
    end

    #intent: match PBN import format. Pro: convenience Con: import format strewn across domain classes.
    # Still, reflection makes it a pain to move this outside this class.  Maybe still move to Pbn?
    def self.for_char(char)
      case char
        when 'T'
          Bridge::Rank::Ten
        when 'J'
          Bridge::Rank::Jack
        when 'Q'
          Bridge::Rank::Queen
        when 'K'
          Bridge::Rank::King
        when 'A'
          Bridge::Rank::Ace
        else
          const_get(NAME_MAP[char.to_i].capitalize.to_sym)
      end
    end

    def initialize(*args)
      raise NoMethodError, 'Cannot initialize a new rank'
    end

    def pretty_print(pp)
      pp.pp inspect
    end

    def inspect
      "#<#{self.class.name} #{to_s}>"
    end
  end
end
