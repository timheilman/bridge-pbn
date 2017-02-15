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
        observer_responded = false
        @observers.each do |observer|
          if observer.respond_to? method_sym
            # disregarded_observer_return_value =
            observer.send(method_sym, *arguments, &block)
            observer_responded = true
          end
        end
        super unless observer_responded
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
