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
      def self.create(logger: Logger.new(STDERR),
                      error_policy: :log_error,
                      io:)
        new(logger: logger, error_policy: error_policy, io: io)
      end

      ##
      # Attach an observer for client-based parsing (and potentially disregard the yields from #import)
      def attach_observer(observer)
        @observer_broadcaster.add_observer(observer)
      end

      ##
      # Invokes methods on observers attached with #attach_observer which respond_to specific methods called
      # by SubgameParsers, as well as done_with_game referenced here.  Yields one Game per game provided by the io.
      def import
        return enum_for(:import) unless block_given?
        game_parser_listener = @injector.game_parser_listener
        attach_observer game_parser_listener
        @injector.io_parser(@io).each_game_string do |game|
          import_game game
          @observer_broadcaster.done_with_game if @observer_broadcaster.respond_to?(:done_with_game)
          yield game_parser_listener.build
        end
      end

      private

      def initialize(logger: Logger.new(STDERR),
                     error_policy: :log_error,
                     io:,
                     injector: Internals::Injector.new)
        @logger = logger
        @injector = injector
        @error_policy = error_policy
        @observer_broadcaster = injector.observer_broadcaster
        @io = io
      end

      def import_game(game)
        game_parser = @injector.game_parser game, @logger, @observer_broadcaster
        safely_parse game_parser
      end

      def safely_parse(game_parser)
        game_parser.parse
      rescue Internals::PortableBridgeNotationError => pbne
        raise StandardError, pbne unless @error_policy == :log_error
        @logger.warn("; unable to parse game due to error: `#{pbne}'") if @error_policy == :log_error
      end
    end
  end
end
