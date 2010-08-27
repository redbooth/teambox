class RemoveExtMemberships < ActiveRecord::Migration
  def self.up
    Membership.find_all_by_role(10).each{|d|d.destroy}
  end

  def self.down
  end
end
