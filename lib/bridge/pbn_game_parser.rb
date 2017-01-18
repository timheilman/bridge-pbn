module Bridge
  class PbnGameParser
    def self.each_tag_and_section pbn_game_string, &block
      block.yield
    end
  end
end