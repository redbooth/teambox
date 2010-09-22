class MakeTeamboxData < ActiveRecord::Migration
  def self.up
    create_table :teambox_datas do |t|
      t.integer :user_id
      t.integer :type_id
      
      t.text :project_ids
      t.text :map_data
      
      t.string   :processed_data_file_name
      t.string   :processed_data_content_type
      t.integer  :processed_data_file_size
      
      t.boolean :is_processing, :default => false
      t.datetime :processed_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :teambox_datas
  end
end
