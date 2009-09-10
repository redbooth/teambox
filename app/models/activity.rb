class Activity < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :user
  belongs_to :project
  
  def self.log(project,target,action)
    activity = Activity.new(
      :project_id => project.id,
      :target => target,
      :action => action)
    activity.save
    activity
  end
end
