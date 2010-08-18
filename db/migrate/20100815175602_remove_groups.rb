class RemoveGroups < ActiveRecord::Migration
  def self.up
    drop_table :groups
    drop_table :groups_users
    remove_column :invitations, :group_id
    remove_column :projects, :group_id
  end

  def self.down
    create_table "groups" do |t|
      t.string   "name",                      :limit => 40
      t.text     "description"
      t.string   "permalink",                 :limit => 40
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
    end

    create_table "groups_users", :id => false do |t|
      t.integer "group_id"
      t.integer "user_id"
    end
    
    add_column :invitations, :group_id, :integer
    add_column :projects, :group_id, :integer
  end
end
