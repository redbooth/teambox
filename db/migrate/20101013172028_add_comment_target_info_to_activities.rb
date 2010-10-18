class AddCommentTargetInfoToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :comment_target_id, :integer
    rename_column :activities, :comment_type, :comment_target_type

    # This can be slow, act cautiously
    Activity.find_each(:conditions => { :target_type => 'Comment' }) do |activity|
      activity.update_attribute :comment_target_id, activity.target.target.id
    end
  end

  def self.down
    remove_column :activities, :comment_target_id
    rename_column :activities, :comment_target_type, :comment_type
  end
end
