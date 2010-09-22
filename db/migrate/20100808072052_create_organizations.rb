class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.string   :name
      t.string   :permalink, :null => false
      t.string   :language,  :default => 'en'
      t.string   :time_zone, :default => "Eastern Time (US & Canada)"
      t.string   :domain
      t.text     :description
      t.datetime :deleted_at
      t.string   :logo_file_name
      t.string   :logo_content_type
      t.integer  :logo_file_size
      t.timestamps
    end

    create_table :memberships do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :role, :default => 20
      t.timestamps
    end
    
    add_column :projects, :organization_id, :integer
  end

  def self.down
    drop_table :organizations
    drop_table :memberships
    remove_column :projects, :organization_id
  end
end
