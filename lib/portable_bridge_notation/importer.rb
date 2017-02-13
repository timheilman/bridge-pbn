require 'logger'

require_relative 'handler'
require_relative 'io_parser'
require_relative 'game_parser'
require_relative 'subgame_parser_chain_factory'

class PortableBridgeNotation::Importer
  def initialize
    @observers = []
  end

  def attach(importObserver)
    @observers << importObserver
  end

  def import(io)
    PortableBridgeNotation::IoParser.each_game_string(io) do |game|
      import_game game
    end
  end

  def import_game game
    PortableBridgeNotation::GameParser.new.each_subgame(game) do |subgame|
      import_subgame subgame
    end
  end

  def import_subgame subgame
    obtain_subgame_handler.handle(subgame)
  end

  def obtain_subgame_handler
    #todo: uggggg I'd love to inject the subgame parser chain, but then from where? OldSchool abstract-factory this
    #todo: fixup filestructure, use Internal namespace like Weirich advised and get everything but Importer into it
    PortableBridgeNotation::SubgameParserChainFactory.new(self, Logger.new(STDOUT)).get_chain
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
