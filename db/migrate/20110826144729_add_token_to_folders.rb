class AddTokenToFolders < ActiveRecord::Migration
  def self.up
    add_column :folders, :token, :string
    add_index :folders, :token
  end

  def self.down
    remove_index :folders, :token
    remove_column :folders, :token
  end
end
