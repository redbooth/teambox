class PrivatePages < ActiveRecord::Migration
  def self.up
    add_column :pages, :is_private, :boolean, :default => false, :null => false
    add_index :pages, :is_private
  end

  def self.down
    remove_column :pages, :is_private
  end
end
