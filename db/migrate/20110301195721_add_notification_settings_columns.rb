class AddNotificationSettingsColumns < ActiveRecord::Migration
  def self.up
    add_column :people, :digest, :integer, :default => 0
    add_column :people, :last_digest_delivery, :datetime
    add_column :people, :next_digest_delivery, :datetime

    add_column :users, :digest_delivery_hour, :integer, :default => 9
  end

  def self.down
    remove_column :people, :digest
    remove_column :people, :last_digest_delivery
    remove_column :people, :next_digest_delivery

    remove_column :users, :digest_delivery_hour
  end
end
