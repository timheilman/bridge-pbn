module PortableBridgeNotation
  module Internals
    class ObserverBroadcaster
      def initialize
        @observers = []
      end

      attr_reader :observers

      def add_observer(observer)
        observers << observer
      end

      def method_missing(method_sym, *arguments, &block)
        observer_responded = false
        observers.each do |observer|
          next unless observer.respond_to? method_sym
          # disregarded_observer_return_value =
          observer.send(method_sym, *arguments, &block)
          observer_responded = true
        end
        super unless observer_responded
      end

      def respond_to_missing?(method_sym, include_private = false)
        observers.each do |observer|
          return true if observer.respond_to? method_sym, include_private
        end
        super
      end
    end
  end
end
