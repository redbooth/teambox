class AddUserMapToTeamboxData < ActiveRecord::Migration
  def self.up
    add_column :teambox_datas, :user_map, :text
  end

  def self.down
    remove_column :teambox_datas, :user_map
  end
end
