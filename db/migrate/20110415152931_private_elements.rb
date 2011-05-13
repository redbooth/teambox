class PrivateElements < ActiveRecord::Migration
  def self.up
    add_column :activities, :is_private, :boolean, :default => false, :null => false
    add_column :comments, :is_private, :boolean, :default => false, :null => false
    add_column :conversations, :is_private, :boolean, :default => false, :null => false
    add_column :tasks, :is_private, :boolean, :default => false, :null => false
    add_column :uploads, :is_private, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :activities, :is_private
    remove_column :comments, :is_private
    remove_column :conversations, :is_private
    remove_column :tasks, :is_private
    remove_column :uploads, :is_private
  end
end
