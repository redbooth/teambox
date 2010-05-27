class AddAvatarUpdatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar_updated_at, :datetime
  end

  def self.down
    remove_column :users, :avatar_updated_at
  end
end
