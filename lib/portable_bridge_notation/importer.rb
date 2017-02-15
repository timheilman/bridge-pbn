require 'logger'

require_relative 'internals/concrete_factory'
require_relative 'internals/portable_bridge_notation_error'

module PortableBridgeNotation
  class Importer
    #todo: is injecting logger even the right error-handling strategy?
    #todo: default-rubocop-comply for full repo
    #todo: rubocop as git pre-commit hook

    def attach_observer(observer)
      @observers << observer
    end

    def import(io)
      @abstract_factory.make_io_parser(io).each_game_string do |game|
        import_game game
      end
    end

    def self.create(logger: Logger.new(STDERR))
      new(logger: logger)
    end

    private

    def initialize(logger: Logger.new(STDERR),
                   abstract_factory: Internals::ConcreteFactory.new)
      @logger = logger
      @abstract_factory = abstract_factory
      @observers = []
    end

    def import_game(game)
      game_parser = @abstract_factory.make_cached_game_parser game
      game_parser.each_subgame do |subgame|
        tag_name = subgame.tagPair[0]
        begin
          subgame_parser = @abstract_factory.make_subgame_parser(self, tag_name) #todo: break multiplexer off self
          subgame_parser.parse subgame
        rescue Internals::PortableBridgeNotationError => pbne
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