require 'logger'

require_relative '../internals/concrete_factory'
require_relative '../internals/portable_bridge_notation_error'

module PortableBridgeNotation
  ##
  # Class for importing Portable Bridge Notation data
  class Importer
    ##
    # Provide an instance. Parsing problems will be reported to client's logger, if provided
    def self.create(logger: Logger.new(STDERR))
      new(logger: logger)
    end

    ##
    # Attach an observer for client-based parsing (and potentially disregard the yields from #import)
    def attach_observer(observer)
      @observer_broadcaster.add_observer(observer)
    end

    ##
    # Invokes methods on observers attached with #attach_observer which respond_to specific methods called
    # by SubgameParsers.  Yields one Game per game provided by the io.
    def import(io)
      # TODO: site to TDD default observer(s) to generate full api structure
      @abstract_factory.make_io_parser(io).each_game_string do |game|
        import_game game
      end
    end

    private

    def initialize(logger: Logger.new(STDERR),
                   abstract_factory: Internals::ConcreteFactory.new)
      @logger = logger
      @abstract_factory = abstract_factory
      @observer_broadcaster = abstract_factory.make_observer_broadcaster
    end

    def import_game(game)
      game_parser = @abstract_factory.make_cached_game_parser game
      game_parser.each_subgame do |subgame|
        tag_name = subgame.tagPair[0]
        begin
          subgame_parser = @abstract_factory.make_subgame_parser(@observer_broadcaster, tag_name)
          subgame_parser.parse subgame
        rescue Internals::PortableBridgeNotationError => pbne
          @logger.warn("; ignoring tag name `#{tag_name}' due to error: `#{pbne}'")
        end
      end
      # TODO: in order to have Note tag values when sections get parsed, we want to delay their parsing
      # until here; provide GameParser's @section_notes to the AuctionSectionParser and PlaySectionParser here,
      # to (finally) send the Auction and Play sections' worth of domain builder API messages
    end
  end
end
