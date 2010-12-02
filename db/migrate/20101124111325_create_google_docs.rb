class CreateGoogleDocs < ActiveRecord::Migration
  def self.up
    create_table :google_docs do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :comment_id
      
      t.string :title
      t.string :document_id
      t.string :document_type
      t.string :url
      t.string :edit_url
      t.string :acl_url
      
      t.datetime :deleted_at
      
      t.timestamps
    end
    
    add_index :google_docs, :project_id
    add_index :google_docs, :user_id
    add_index :google_docs, :comment_id
  end

  def self.down
    remove_index :google_docs, :comment_id
    remove_index :google_docs, :user_id
    remove_index :google_docs, :project_id
    drop_table :google_docs
  end
end