module Bridge
  class Strain < Struct.new(:order, :key)
    include Comparable

    def <=>(other)
      order <=> other&.order
    end

    def to_s
      key.to_s
    end

    #TODO: re-establish whitespace for horizontal alignment
    Club = new(0, :club).freeze
    Diamond = new(1, :diamond).freeze
    Heart = new(2, :heart).freeze
    Spade = new(3, :spade).freeze
    NoTrump = new(4, :no_trump).freeze

    @all = [Club, Diamond, Heart, Spade, NoTrump].sort.freeze
    @suits = (@all - [NoTrump]).freeze

    def self.all
      @all
    end

    def self.suits # suits that can be used on cards
      @suits
    end

    def initialize(*args)
      raise NoMethodError, 'Cannot initialize a new suit'
    end

    def self.for_string(strain_string)
      case strain_string
        when 'C'
          Bridge::Strain::Club
        when 'D'
          Bridge::Strain::Diamond
        when 'H'
          Bridge::Strain::Heart
        when 'S'
          Bridge::Strain::Spade
        when 'NT'
          Bridge::Strain::NoTrump
        else
          raise ArgumentError.new 'Got unidentifiable strain strain_string: `' + strain_string + "'"
      end
    end
  end
end
