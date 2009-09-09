class Activity < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :user
  belongs_to :project
  
  def self.log(project,target,action)
    activity = Activity.new(
      :project_id => project.id,
      :target_id => target.id,
      :target_type => target.class.name,
      :action => action)
    activity.save
    activity
  end
end
