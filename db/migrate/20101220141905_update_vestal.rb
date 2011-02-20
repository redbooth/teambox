class UpdateVestal < ActiveRecord::Migration
  def self.up
    rename_column :versions, :changes, :modifications
  end

  def self.down
    rename_column :versions, :modifications, :changes
  end
end
