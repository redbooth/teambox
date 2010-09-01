class AddIndexesToFindOrganizations < ActiveRecord::Migration
  def self.up
    add_index :organizations, :permalink
    add_index :organizations, :domain
  end

  def self.down
    remove_index :organizations, :permalink
    remove_index :organizations, :domain
  end
end
