class AddIndexToInvitations < ActiveRecord::Migration
  def self.up
    add_index :invitations, [:project_id]
    add_index :invitations, [:user_id]
  end

  def self.down
    remove_index :invitations, :column => [:project_id]
    remove_index :invitations, :column => [:user_id]
  end
end
