class PrivateElements < ActiveRecord::Migration
  def self.up
    add_column :activities, :is_private, :boolean, :default => false
    add_column :conversations, :is_private, :boolean, :default => false
    add_column :tasks, :is_private, :boolean, :default => false
  end

  def self.down
    remove_column :activities, :is_private
    remove_column :conversations, :is_private
    remove_column :tasks, :is_private
  end
end
