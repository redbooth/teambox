class DeletedTeamboxData < ActiveRecord::Migration
  def self.up
    add_column :teambox_datas, :deleted_at, :datetime
  end

  def self.down
    remove_column :teambox_datas, :deleted_at
  end
end
