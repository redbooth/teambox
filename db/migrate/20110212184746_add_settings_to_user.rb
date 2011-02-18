class AddSettingsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :settings, :text
  end

  def self.down
    remove_column :users, :settings
  end
end
