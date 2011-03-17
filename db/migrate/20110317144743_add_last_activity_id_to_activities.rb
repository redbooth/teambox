class AddLastActivityIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :last_activity_id, :integer
    add_index  :activities, :last_activity_id
    add_index  :activities, :comment_target_type
    add_index  :activities, :comment_target_id
  end

  def self.down
    remove_index  :activities, :comment_target_id
    remove_index  :activities, :comment_target_type
    remove_column :activities, :last_activity_id
  end
end
