class AddIndexToTasksAssignedId < ActiveRecord::Migration
  def self.up
    add_index :tasks, :assigned_id
  end

  def self.down
    remove_index :tasks, :assigned_id
  end
end
