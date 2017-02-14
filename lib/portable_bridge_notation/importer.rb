require 'logger'

require_relative 'subgame_builder'
require_relative 'subgame_parser_dispatcher'
require_relative 'io_parser'
require_relative 'game_parser'

class PortableBridgeNotation::Importer
  #todo: fixup filestructure, use Internal namespace like Weirich advised and get everything but Importer into it

  def self.create(logger: Logger.new(STDERR))
    new(subgame_builder: PortableBridgeNotation::SubgameBuilder.new, logger: logger)
  end

  def attach(importObserver)
    @observers << importObserver
  end

  def import(io)
    PortableBridgeNotation::IoParser.new(io).each_game_string do |game|
      import_game game
    end
  end

  private

  def initialize(subgame_builder: subgame_builder, subgame_parser: subgame_parser, logger: logger)
    @observers = []
    @subgame_builder = subgame_builder
    @subgame_parser = PortableBridgeNotation::SubgameParserDispatcher.new(self, logger)
  end

  def import_game(game)
    game_parser = PortableBridgeNotation::GameParser.new(subgame_builder: @subgame_builder, pbn_game_string: game)
    game_parser.each_subgame do |subgame|
      @subgame_parser.parse subgame
    end
    # todo: in order to have Note tag values when sections get parsed, we want to delay their parsing
    # until here; provide GameParser's @section_notes to the AuctionSectionParser and PlaySectionParser here,
    # to (finally) send the Auction and Play sections' worth of domain builder API messages
  end

  def method_missing(method_sym, *arguments, &block)
    @observers.each do |observer|
      if observer.respond_to? method_sym
        return observer.send(method_sym, *arguments, &block)
      end
    end
    super
  end

  def self.respond_to?(method_sym, include_private = false)
    @observers.each do |observer|
      if observer.respond_to? method_sym, include_private
        return true
      end
    end
    super
  end

end
