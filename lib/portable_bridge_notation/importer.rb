require 'logger'

require_relative 'internals/io_parser'
require_relative 'internals/portable_bridge_notation_error'
require_relative 'internals/subgame_builder'
require_relative 'internals/game_parser'
require_relative 'internals/subgame_parser_factory'
require_relative 'internals/game_parser_factory'

module PortableBridgeNotation
  class Importer
    #todo: is injecting logger even the right error-handling strategy?
    #todo: default-rubocop-comply for full repo
    #todo: rubocop as git pre-commit hook

    def attach(importObserver)
      @observers << importObserver
    end

    def import(io)
      @io_parser_class.new(io).each_game_string do |game|
        import_game game
      end
    end

    def create(logger: Logger.new(STDERR))
      new(logger: logger)
    end

    private

    def initialize(logger: Logger.new(STDERR), # passed in from outside
                   subgame_builder: Internals::SubgameBuilder.new, # cleared between uses; singleton; lives per-import
                   subgame_parser_factory: Internals::SubgameParserFactory, # good, I like this usage, and is a self. method: lives per-ruby-process
                   game_parser_state_factory_class: Internals::GameParserStates::GameParserFactory, # bad: its c'tors args could be per-import, so it could be per-import
                   game_parser_class: Internals::GameParser, # bad: lives per-game and not presently cleared; make live per-import
                   io_parser_class: Internals::IoParser) # good:
      @observers = []
      @subgame_builder = subgame_builder
      @logger = logger
      @subgame_parser_factory = subgame_parser_factory
      @game_parser_class = game_parser_class
      @io_parser_class = io_parser_class
      @game_parser_state_factory_class = game_parser_state_factory_class
    end

    def import_game(game)
      game_parser = @game_parser_class.new(
          subgame_builder: @subgame_builder,
          pbn_game_string: game,
          game_parser_state_factory_class: @game_parser_state_factory_class)
      game_parser.each_subgame do |subgame|
        tag_name = subgame.tagPair[0]
        begin
          subgame_parser = @subgame_parser_factory.make_subgame_parser(self, tag_name) #todo: break multiplexer off self
          subgame_parser.parse subgame
        rescue Internals::PortableBridgeNotationError => pbne # todo: ensure all exceptions raised during subgames are these
          @logger.warn("; ignoring tag name #{tag_name} due to error: #{pbne.to_s}")
        end
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