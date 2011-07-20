class AddTaskCountsColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :assigned_tasks_count,  :integer
    add_column :users, :completed_tasks_count, :integer
  end

  def self.down
    remove_column :users, :assigned_tasks_count
    remove_column :users, :completed_tasks_count
  end
end