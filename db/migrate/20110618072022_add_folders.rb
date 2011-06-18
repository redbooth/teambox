class AddFolders < ActiveRecord::Migration
  def self.up
    create_table "folders" do |t|
      t.string   "name"
      t.integer  "user_id"
      t.integer  "project_id"
      t.integer  "parent_folder_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "deleted", :default => false, :null => false
    end

    add_column :uploads, :parent_folder_id, :integer
  end

  def self.down
    drop_table :uploads
  end
end
