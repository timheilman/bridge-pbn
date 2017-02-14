require 'logger'

require_relative 'internals/io_parser'
require_relative 'internals/subgame_builder'
require_relative 'internals/game_string_parser'
require_relative 'internals/subgame_parser_dispatcher'

module PortableBridgeNotation
  class Importer
    #todo: is injecting logger even the right error-handling strategy?
    #todo: default-rubocop-comply for full repo
    #todo: rubocop as git pre-commit hook
    def self.create(logger: Logger.new(STDERR))
      new(subgame_builder: Internals::SubgameBuilder.new, logger: logger)
    end

    def attach(importObserver)
      @observers << importObserver
    end

    def import(io)
      Internals::IoParser.new(io).each_game_string do |game|
        import_game game
      end
    end

    private

    def initialize(subgame_builder:, logger:)
      @observers = []
      @subgame_builder = subgame_builder
      @subgame_parser = Internals::SubgameParserDispatcher.new(self, logger)
    end

    def import_game(game)
      game_parser = Internals::GameStringParser.new(subgame_builder: @subgame_builder, pbn_game_string: game)
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
end