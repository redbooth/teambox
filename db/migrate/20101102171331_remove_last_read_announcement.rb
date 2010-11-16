class RemoveLastReadAnnouncement < ActiveRecord::Migration
  def self.up
    remove_column :users, :last_read_announcement
  end

  def self.down
    add_column :users, :last_read_announcement, :datetime
  end
end
