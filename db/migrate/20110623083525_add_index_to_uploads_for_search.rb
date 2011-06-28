class AddIndexToUploadsForSearch < ActiveRecord::Migration
  def self.up
    add_index :uploads, [:page_id, :asset_file_name]
    remove_index :uploads, :column => [:page_id]
  end

  def self.down
    add_index :uploads, [:page_id]
    remove_index :uploads, :column => [:page_id, :asset_file_name]
  end
end
