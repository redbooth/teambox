class MembershipWithRoles < ActiveRecord::Migration
  def self.up
    add_column :memberships, :role, :integer, :default => 20 # participant
    remove_column :memberships, :admin
  end

  def self.down
    remove_column :memberships, :role
    add_column :memberships, :admin, :boolean, :default => true
  end

end
