module Socialization
  module ActiveRecordStores
    class WatchLater < ActiveRecord::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::WatchLater
      extend Socialization::ActiveRecordStores::Mixins::Base

      belongs_to :watcher,    :polymorphic => true
      belongs_to :watchable, :polymorphic => true

      scope :watched_by, lambda { |watcher| where(
        :watcher_type    => watcher.class.name.classify,
        :watcher_id      => watcher.id)
      }

      scope :watching,   lambda { |watchable| where(
        :watchable_type => watchable.class.name.classify,
        :watchable_id   => watchable.id)
      }

      class << self
        def watch!(watcher, watchable, opts = {})
          unless watches?(watcher, watchable)
            self.create! do |watch|
              watch.watcher = watcher
              watch.watchable = watchable
              watch.expire_at = opts[:expire_at] if opts[:expire_at].class == Time
            end
            update_counter(watcher, watchees_count: +1)
            update_counter(watchable, watchers_count: +1)
            call_after_create_hooks(watcher, watchable)
            true
          else
            false
          end
        end

        def unwatch!(watcher, watchable)
          if watches?(watcher, watchable)
            watch_for(watcher, watchable).destroy_all
            update_counter(watcher, watchees_count: -1)
            update_counter(watchable, watchers_count: -1)
            call_after_destroy_hooks(watcher, watchable)
            true
          else
            false
          end
        end

        def watches?(watcher, watchable)
          !watch_for(watcher, watchable).empty?
        end

        # Returns an ActiveRecord::Relation of all the watchers of a certain type that are watching  watchable
        def watchers_relation(watchable, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:watcher_id).
              where(:watcher_type => klass.name.classify).
              where(:watchable_type => watchable.class.to_s).
              where(:watchable_id => watchable.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the watchers of a certain type that are watching  watchable
        def watchers(watchable, klass, opts = {})
          rel = watchers_relation(watchable, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.to_a
          else
            rel
          end
        end

        # Returns an ActiveRecord::Relation of all the watchables of a certain type that are watched by watcher
        def watchables_relation(watcher, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:watchable_id).
              where(:watchable_type => klass.name.classify).
              where(:watcher_type => watcher.class.to_s).
              where(:watcher_id => watcher.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the watchables of a certain type that are watched by watcher
        def watchables(watcher, klass, opts = {})
          rel = watchables_relation(watcher, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.to_a
          else
            rel
          end
        end

        # Remove all the watchers for watchable
        def remove_watchers(watchable)
          self.where(:watchable_type => watchable.class.name.classify).
               where(:watchable_id => watchable.id).destroy_all
        end

        # Remove all the watchables for watcher
        def remove_watchables(watcher)
          self.where(:watcher_type => watcher.class.name.classify).
               where(:watcher_id => watcher.id).destroy_all
        end

      private
        def watch_for(watcher, watchable)
          watched_by(watcher).watching( watchable)
        end
      end # class << self

    end
  end
end