class AddSettingsFieldToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :settings, :text
  end

  def self.down
    remove_column :organizations, :settings
  end
end
