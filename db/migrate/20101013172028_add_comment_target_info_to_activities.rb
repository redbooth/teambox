class AddCommentTargetInfoToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :comment_target_id, :integer
    rename_column :activities, :comment_type, :comment_target_type
    Activity.update_all "comment_target_id = (select comments.target_id from comments where comments.id = activities.target_id)", "target_type = 'Comment'"
  end

  def self.down
    remove_column :activities, :comment_target_id
    rename_column :activities, :comment_target_type, :comment_type
  end
end
