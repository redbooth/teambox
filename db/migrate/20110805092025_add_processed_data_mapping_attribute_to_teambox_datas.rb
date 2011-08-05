class AddProcessedDataMappingAttributeToTeamboxDatas < ActiveRecord::Migration
  def self.up
    add_column :teambox_datas, :processed_data_mapping, :text
  end

  def self.down
    remove_column :teambox_datas, :processed_data_mapping
  end
end
