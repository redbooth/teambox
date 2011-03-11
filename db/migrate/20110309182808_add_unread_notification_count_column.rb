class AddUnreadNotificationCountColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :unread_notifications_count, :integer, :default => 0
    User.find_each do |user|
      user.unread_notifications_count = user.unread_notifications.count
      user.save
    end
  end

  def self.down
    remove_column :users, :unread_notifications_count
  end
end
