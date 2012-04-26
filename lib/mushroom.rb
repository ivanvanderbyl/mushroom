require 'mushroom/version'
require 'active_support'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/class/attribute'
require 'active_support/inflector'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/aliasing'

module Mushroom
  extend ActiveSupport::Concern

  autoload :Subscriber, 'mushroom/subscriber'

  included do
    class_eval do
      # Public: Instrument a method call
      #
      # Example:
      #   def start
      #     # work hard here
      #   end
      #   instrument :start
      #
      def self.instrument(method, options = {})
        define_method(:"#{method}_with_instrument") do |*args, &block|
          instrument(method) do
            send(:"#{method}_without_instrument", *args, &block)
          end
        end
        alias_method_chain method, 'instrument'
      end
    end
  end

  class << self
    def event_name(event, sender)
      if sender.is_a?(String)
        klass_name = sender
      else
        klass_name = sender.respond_to?(:ancestors) && sender.ancestors.first == sender ? sender.name : sender.class.name
      end
      [klass_name.demodulize.underscore.gsub('/', ':'), event.to_s].join(':')
    end
  end

  def notify(event, *args)
    instrument(event, *args) {}
  end

  def instrument(event, *args, &block)
    event = Mushroom.event_name(event, self)
    ActiveSupport::Notifications.instrument(event.to_s, :target => self, :args => args, &block)
  end

end
