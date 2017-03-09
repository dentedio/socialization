class CreateWatchLaters < ActiveRecord::Migration
  def change
    create_table :watch_laters do |t|
      t.string  :watcher_type
      t.integer :watcher_id
      t.string  :watchable_type
      t.integer :watchable_id
      t.datetime :created_at
      t.datetime :expire_at
    end

    add_index :watch_laters, ["watcher_id", "watcher_type"], :name => "watchers"
    add_index :watch_laters, ["watchable_id", "watchable_type"], :name => "watchables"
  end
end