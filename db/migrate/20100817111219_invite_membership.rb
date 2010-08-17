class InviteMembership < ActiveRecord::Migration
  def self.up
    add_column :invitations, :membership, :integer, :default => 10
  end

  def self.down
    remove_column :invitations, :membership
  end
end
