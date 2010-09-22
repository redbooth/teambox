class RemoveNotifyComments < ActiveRecord::Migration
  def self.up
    remove_column :users, :notify_task_lists
  end

  def self.down
    add_column :users, :notify_task_lists, :boolean
  end
end
