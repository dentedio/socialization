module ActiveRecord
  class Base
    def is_watcher?
      false
    end
    alias watcher? is_watcher?
  end
end

module Socialization
  module Watcher
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.watch_later_model.remove_watchables(self) }

      # Specifies if self can queue {Watchable} objects.
      #
      # @return [Boolean]
      def is_watcher?
        true
      end
      alias watcher? is_watcher?

      # Create a new {Watch watch} relationship.
      #
      # @param [Watchable] watchable the object to be watched.
      # @return [Boolean]
      def watch!(watchable, opts = {})
        raise Socialization::ArgumentError, "#{watchable} is not watchable!"  unless watchable.respond_to?(:is_watchable?) && watchable.is_watchable?
        Socialization.watch_later_model.watch!(self, watchable, opts)
      end

      # Delete a {Watch watch} relationship.
      #
      # @param [Watchable] watchable the object to unwatch.
      # @return [Boolean]
      def unwatch!(watchable)
        raise Socialization::ArgumentError, "#{watchable} is not watchable!" unless watchable.respond_to?(:is_watchable?) && watchable.is_watchable?
        Socialization.watch_later_model.unwatch!(self, watchable)
      end

      # Toggles a {Watch watch} relationship.
      #
      # @param [Watchable] watchable the object to watch/unwatch.
      # @return [Boolean]
      def toggle_watch!(watchable)
        raise Socialization::ArgumentError, "#{watchable} is not watchable!" unless watchable.respond_to?(:is_watchable?) && watchable.is_watchable?
        if watches?(watchable)
          unwatch!(watchable)
          false
        else
          watch!(watchable)
          true
        end
      end

      # Specifies if self watches a {Watchable} object.
      #
      # @param [Watchable] watchable the {Watchable} object to test against.
      # @return [Boolean]
      def watches?(watchable)
        raise Socialization::ArgumentError, "#{watchable} is not watchable!" unless watchable.respond_to?(:is_watchable?) && watchable.is_watchable?
        Socialization.watch_later_model.watches?(self, watchable)
      end

      # Returns all the watchables of a certain type that are watched by self
      #
      # @params [Watchable] klass the type of {Watchable} you want
      # @params [Hash] opts a hash of options
      # @return [Array<Watchable, Numeric>] An array of Watchable objects or IDs
      def watchables(klass, opts = {})
        Socialization.watch_later_model.watchables(self, klass, opts)
      end
      alias :watchees :watchables

      # Returns a relation for all the watchables of a certain type that are watched by self
      #
      # @params [Watchable] klass the type of {Watchable} you want
      # @params [Hash] opts a hash of options
      # @return ActiveRecord::Relation
      def watchables_relation(klass, opts = {})
        Socialization.watch_later_model.watchables_relation(self, klass, opts)
      end
      alias :watchees_relation :watchables_relation
    end
  end
end