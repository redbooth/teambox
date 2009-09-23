class Activity < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :user
  belongs_to :project

  named_scope :for_task_lists, :conditions => "target_type = 'TaskList' || target_type = 'Task' || comment_type = 'TaskList' || comment_type = 'Task'"
      
  def self.log(project,target,action,creator_id)
    if target.class.to_s == 'Comment'
      comment_type = target.target_type
    else
      comment_type = nil
    end
        
    activity = Activity.new(
      :project_id => project.id,
      :target => target,
      :action => action,
      :user_id => creator_id,
      :comment_type => comment_type)
    activity.save
    activity
  end
end
