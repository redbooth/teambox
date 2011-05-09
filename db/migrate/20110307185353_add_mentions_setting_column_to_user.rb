class AddMentionsSettingColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :instant_notification_on_mention, :boolean, :default => true
  end

  def self.down
    remove_column :users, :instant_notification_on_mention
  end
end
