class AddUrgentFlagToTasksAndComments < ActiveRecord::Migration
  def self.up
    add_column :tasks, :urgent, :boolean, :default => false, :null => false
    add_column :comments, :urgent, :boolean, :default => false, :null => false
    add_column :comments, :previous_urgent, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :tasks, :urgent
    remove_column :comments, :urgent, :previous_urgent
  end
end
