class RemoveExtMemberships < ActiveRecord::Migration
  def self.up
    Membership.delete_all(:role => 10)
  end

  def self.down
  end
end
