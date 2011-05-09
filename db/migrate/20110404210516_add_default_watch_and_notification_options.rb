class AddDefaultWatchAndNotificationOptions < ActiveRecord::Migration
  def self.up
    add_column :users, :default_digest,                 :integer, :default => 0
    add_column :users, :default_watch_new_task,         :boolean, :default => false
    add_column :users, :default_watch_new_conversation, :boolean, :default => false
  end

  def self.down
    remove_column :users, :default_digest
    remove_column :users, :default_watch_new_task
    remove_column :users, :default_watch_new_conversation
  end
end
