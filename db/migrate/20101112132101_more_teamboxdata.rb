class MoreTeamboxdata < ActiveRecord::Migration
  def self.up
    add_column :teambox_datas, :processed_objects, :text
    add_column :teambox_datas, :service, :string
    add_column :teambox_datas, :status, :integer, :default => 0
    remove_column :teambox_datas, :is_processing
  end

  def self.down
    add_column :teambox_datas, :is_processing, :boolean, :default => false
    remove_column :teambox_datas, :processed_objects
    remove_column :teambox_datas, :service
    remove_column :teambox_datas, :status
  end
end
