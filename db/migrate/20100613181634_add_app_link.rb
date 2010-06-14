class AddAppLink < ActiveRecord::Migration
  def self.up
    create_table :app_links do |t|
      t.integer  :user_id
      t.string   :provider
      t.string   :app_user_id
      t.text     :custom_attributes
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :app_links, :user_id
  end

  def self.down
    drop_table :app_links
    remove_index :app_links, :column => :user_id
  end
end
