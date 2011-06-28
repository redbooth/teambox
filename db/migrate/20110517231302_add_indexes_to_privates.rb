class AddIndexesToPrivates < ActiveRecord::Migration
  def self.up
    add_index :activities, :is_private
    add_index :comments, :is_private
    add_index :conversations, :is_private
    add_index :tasks, :is_private
    add_index :uploads, :is_private
  end

  def self.down
    remove_index :activities, :is_private
    remove_index :comments, :is_private
    remove_index :conversations, :is_private
    remove_index :tasks, :is_private
    remove_index :uploads, :is_private
  end
end
