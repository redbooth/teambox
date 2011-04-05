class AddWatchablePagesOptions < ActiveRecord::Migration
  def self.up
    add_column :users, :default_watch_new_page, :boolean, :default => false
    add_column :people, :watch_new_page,        :boolean, :default => false
  end

  def self.down
    add_remove :users, :default_watch_new_page
    add_remove :people, :watch_new_page
  end
end
