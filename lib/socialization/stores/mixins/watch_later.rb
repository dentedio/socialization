module Socialization
  module Stores
    module Mixins
      module WatchLater

      public
        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise Socialization::ArgumentError unless [:all, :watcher, :watchable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_watch(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unwatch(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      protected
        def call_after_create_hooks(watcher, watchable)
          self.send(@after_create_hook, watcher, watchable) if @after_create_hook
          touch_dependents(watcher, watchable)
        end

        def call_after_destroy_hooks(watcher, watchable)
          self.send(@after_destroy_hook, watcher, watchable) if @after_destroy_hook
          touch_dependents(watcher, watchable)
        end

      end
    end
  end
end