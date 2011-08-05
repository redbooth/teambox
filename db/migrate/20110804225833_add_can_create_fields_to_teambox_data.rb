class AddCanCreateFieldsToTeamboxData < ActiveRecord::Migration
  def self.up
    add_column :teambox_datas, :can_create_users, :boolean
    add_column :teambox_datas, :can_create_organizations, :boolean
  end

  def self.down
    remove_column :teambox_datas, :can_create_organizations
    remove_column :teambox_datas, :can_create_users
  end
end
