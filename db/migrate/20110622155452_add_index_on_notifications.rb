class AddIndexOnNotifications < ActiveRecord::Migration
  def self.up
    add_index :notifications, :comment_id
  end

  def self.down
    remove_index :notifications, :comment_id
  end
end
