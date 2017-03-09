module ActiveRecord
  class Base
    def is_watchable?
      false
    end
    alias watchable? is_watchable?
  end
end

module Socialization
  module Watchable
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.watch_later_model.remove_watchers(self) }

      # Specifies if self can be watched.
      #
      # @return [Boolean]
      def is_watchable?
        true
      end
      alias watchable? is_watchable?

      # Specifies if self is watched by a {Watcher} object.
      #
      # @return [Boolean]
      def watched_by?(watcher)
        raise Socialization::ArgumentError, "#{watcher} is not watcher!"  unless watcher.respond_to?(:is_watcher?) && watcher.is_watcher?
        Socialization.watch_later_model.watches?(watcher, self)
      end

      # Returns an array of {Watcher}s watching self.
      #
      # @param [Class] klass the {Watcher} class to be included. e.g. `User`
      # @return [Array<Watcher, Numeric>] An array of Watcher objects or IDs
      def watchers(klass, opts = {})
        Socialization.watch_later_model.watchers(self, klass, opts)
      end

      # Returns a scope of the {Watcher}s watching self.
      #
      # @param [Class] klass the {Watcher} class to be included in the scope. e.g. `User`
      # @return ActiveRecord::Relation
      def watchers_relation(klass, opts = {})
        Socialization.watch_later_model.watchers_relation(self, klass, opts)
      end

    end
  end
end