class AutoacceptInvites < ActiveRecord::Migration
  def self.up
    add_column :users, :auto_accept_invites, :boolean, :default => true
  end

  def self.down
    remove_column :users, :auto_accept_invites
  end
end
