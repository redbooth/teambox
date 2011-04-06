class AddWatchablePagesOptions < ActiveRecord::Migration
  def self.up
    add_column :users,  :default_watch_new_page, :boolean, :default => false
    add_column :users,  :notify_pages,           :boolean, :default => false
    add_column :people, :watch_new_page,        :boolean, :default => false
  end

  def self.down
    remove_column :users, :default_watch_new_page
    remove_column :users, :notify_pages
    remove_column :people, :watch_new_page
  end
end
