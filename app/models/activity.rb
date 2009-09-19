class Activity < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :user
  belongs_to :project

  named_scope :for_task_list, :conditions => "target_type = 'TaskList' || target_type = 'Task'"
    
  def self.log(project,target,action,creator_id)
    activity = Activity.new(
      :project_id => project.id,
      :target => target,
      :action => action,
      :user_id => creator_id)
    activity.save
    activity
  end
end
