module Bridge
  class Game
    attr_accessor :players

    def self.random
      @players = Card.deal.map do |cards|
        Player.new Hand.new(cards)
      end

    end
  end
end
