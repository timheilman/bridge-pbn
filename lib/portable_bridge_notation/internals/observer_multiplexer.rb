module PortableBridgeNotation
  module Internals
    class ObserverMultiplexer
      def initialize
        @observers = []
      end
      def add_observer(observer)
        @observers << observer
      end

      def method_missing(method_sym, *arguments, &block)
        @observers.each do |observer|
          if observer.respond_to? method_sym
            # todo: TDD-fix this unintended behavior: all responsive observers should receive the send!
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
end
