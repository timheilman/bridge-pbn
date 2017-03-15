require 'logger'

require_relative '../internals/injector'
require_relative '../internals/portable_bridge_notation_error'

module PortableBridgeNotation
  module Api
    ##
    # Class for importing Portable Bridge Notation data
    class Importer
      ##
      # Provide an instance. Parsing problems will be reported to client's logger, if provided
      # error_policy may alternately be :raise_error
      def self.create(logger: Logger.new(STDERR), error_policy: :log_error)
        new(logger: logger, error_policy: error_policy)
      end

      ##
      # Attach an observer for client-based parsing (and potentially disregard the yields from #import)
      def attach_observer(observer)
        @observer_broadcaster.add_observer(observer)
      end

      ##
      # Invokes methods on observers attached with #attach_observer which respond_to specific methods called
      # by SubgameParsers, as well as done_with_game referenced here.  Yields one Game per game provided by the io.
      def import(io, &block)
        return enum_for(:import) unless block_given?
        game_parser_listener = @injector.game_parser_listener
        attach_observer game_parser_listener
        @injector.io_parser(io).each_game_string do |game|
          import_game game
          @observer_broadcaster.done_with_game if @observer_broadcaster.respond_to?(:done_with_game)
          block.yield game_parser_listener.build
        end
      end

      private

      def initialize(logger: Logger.new(STDERR),
                     error_policy: :log_error,
                     injector: Internals::Injector.new)
        @logger = logger
        @injector = injector
        @error_policy = error_policy
        @observer_broadcaster = injector.observer_broadcaster
      end

      def import_game(game)
        game_parser = @injector.game_parser game
        game_parser.each_subgame do |subgame|
          tag_name = subgame.tagPair[0]
          safely_parse subgame, tag_name
        end
      end

      def safely_parse(subgame, tag_name)
        subgame_parser = @injector.subgame_parser(@observer_broadcaster, tag_name)
        subgame_parser.parse subgame
      rescue Internals::PortableBridgeNotationError => pbne
        raise pbne unless @error_policy == :log_error
        @logger.warn("; ignoring tag name `#{tag_name}' due to error: `#{pbne}'") if @error_policy == :log_error
      end
    end
  end
end
