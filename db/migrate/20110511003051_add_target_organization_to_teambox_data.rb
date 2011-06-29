class AddTargetOrganizationToTeamboxData < ActiveRecord::Migration
  def self.up
    add_column :teambox_datas, :organization_id, :integer
  end

  def self.down
    remove_column :teambox_datas, :organization_id
  end
end
