class AddWriteLockToGoogleDocs < ActiveRecord::Migration
  def self.up
    add_column :google_docs, :write_lock, :boolean, :default => false
  end

  def self.down
    remove_column :google_docs, :write_lock
  end
end
