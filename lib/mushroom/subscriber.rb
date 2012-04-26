require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/slice'

module Mushroom
  class Subscriber

    attr_reader :event
    delegate :payload, :name, :time, :transaction_id, :duration, :to => :event
    
    def initialize(event)
      @event = event
    end

    # The endpoint for notifications
    def notify
      raise NotImplementedError
    end

    def target
      payload[:target]
    end

    class << self

      # Public: Setter and getter for events
      #
      # Can be called multiple times to set events on a Subscriber.
      #
      # Events cannot be inherited by subclassed objects.
      #
      # Example:
      #   class Handler < Mushroom::Subscriber
      #     events :start, :on => Server
      #     events :stop, :on => [Server, Time]
      #     events :register, :activate, :on => [User]
      #   end
      #
      # Returns: Array of current event registrations.
      def events(*events_and_options)
        if events_and_options.empty?
          self._events
        else
          create_event_subscription(*events_and_options)
        end
      end

      # Internal: Trigger the notification within this subscriber
      def notify(event)
        instance = new(event)

        if instance.method(:notify).arity == 0
          instance.notify
        elsif instance.method(:notify).arity > 0
          instance.notify(*event.payload[:args])
        end
      end

      protected

      def _events
        Thread.current[:"_events_#{object_id}"] ||= []
      end

      def _events=(hash)
        Thread.current[:"_events_#{object_id}"] = []
      end

      def create_event_subscription(*events_and_options)
        options = {
          :on => nil
        }.update(events_and_options.extract_options!)

        targets = Array(options[:on]) || raise(ArgumentError, "Event subscription must include :on => Class")

        targets.each do |target|
          events_and_options.each do |event|
            event = Mushroom.event_name(event, target)

            # Actually subscribe the event
            ActiveSupport::Notifications.subscribe(event) do |*args|
              self.notify(ActiveSupport::Notifications::Event.new(*args))
            end

            (self._events ||=[]).push(event)
          end
        end

        return self._events
      end
    end

  end
end
