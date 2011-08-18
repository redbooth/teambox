class AddIndexOnUploadsToken < ActiveRecord::Migration
  def self.up
    add_index :uploads, :token
  end

  def self.down
    remove_index :uploads, :token
  end
end
