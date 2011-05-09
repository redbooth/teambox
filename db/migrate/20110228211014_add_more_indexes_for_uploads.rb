class AddMoreIndexesForUploads < ActiveRecord::Migration
  def self.up
    add_index :uploads, [:project_id, :deleted, :updated_at]
  end

  def self.down
    remove_index :uploads, [:project_id, :deleted, :updated_at]
  end
end
