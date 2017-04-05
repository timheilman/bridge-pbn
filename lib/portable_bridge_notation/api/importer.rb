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
      def self.create(io:,
                      logger: Logger.new(STDERR),
                      error_policy: :log_error)
        new(logger: logger, error_policy: error_policy, io: io)
      end

      ##
      # Attach an observer for client-based parsing (and potentially disregard the yields from #import)
      def attach_observer(observer)
        observer_broadcaster.add_observer(observer)
      end

      ##
      # Invokes methods on observers attached with #attach_observer which respond_to specific methods called
      # by GameParserStates, as well as done_with_game referenced here.  Yields one Game per game provided by the io.
      def import(&block)
        return enum_for(:import) unless block_given?
        self.block = block
        import_with_block
      end

      private

      attr_reader :observer_broadcaster
      attr_reader :injector
      attr_reader :io
      attr_reader :logger
      attr_reader :error_policy
      attr_accessor :block
      attr_accessor :game_parser_listener

      def initialize(logger:,
                     error_policy:,
                     io:,
                     injector: Internals::Injector.new)
        @logger = logger
        @injector = injector
        @error_policy = error_policy
        @observer_broadcaster = injector.observer_broadcaster
        @io = io
      end

      def import_with_block
        self.game_parser_listener = injector.game_parser_listener
        attach_observer game_parser_listener
        import_with_all_observers
      end

      def import_with_all_observers
        injector.io_parser(io).each_game_string do |game|
          import_single_game game
          observer_broadcaster.done_with_game if observer_broadcaster.respond_to?(:done_with_game)
          block.yield game_parser_listener.build
        end
      end

      def import_single_game(game)
        game_parser = injector.game_parser game, logger, observer_broadcaster
        safely_parse game_parser
      end

      def safely_parse(game_parser)
        game_parser.parse
      rescue Internals::PortableBridgeNotationError => pbne
        raise StandardError, pbne unless error_policy == :log_error
        logger.warn("; unable to parse game due to error: `#{pbne}'") if error_policy == :log_error
      end
    end
  end
end
