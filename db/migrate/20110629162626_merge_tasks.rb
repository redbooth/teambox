class MergeTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :merged_task_id, :integer
    add_column :comments, :merged_with_task_id, :integer
  end

  def self.down
    remove_column :tasks, :merged_task_id, :integer
    remove_column :comments, :merged_with_task_id, :integer
  end
end
