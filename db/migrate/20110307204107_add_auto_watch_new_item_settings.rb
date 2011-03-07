class AddAutoWatchNewItemSettings < ActiveRecord::Migration
  def self.up
    add_column :people, :watch_new_task, :boolean, :default => false
    add_column :people, :watch_new_conversation, :boolean, :default => false
  end

  def self.down
    remove_column :people, :watch_new_task
    remove_column :people, :watch_new_conversation
  end
end
