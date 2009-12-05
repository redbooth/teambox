class Activity < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :user
  belongs_to :project
  acts_as_paranoid

  named_scope :for_task_lists, :conditions => "target_type = 'TaskList' || target_type = 'Task' || comment_type = 'TaskList' || comment_type = 'Task'"
      
  def self.log(project,target,action,creator_id)
    project_id = project.nil? ? nil : project.id

    if target.is_a? Comment
      comment_type = target.target_type
    else
      comment_type = nil
    end
        
    activity = Activity.new(
      :project_id => project_id,
      :target => target,
      :action => action,
      :user_id => creator_id,
      :created_at => target.created_at,
      :comment_type => comment_type)
    activity.save
    activity
  end

  def action_comment_type
    i = "#{action}#{target_type}"
    i +="#{comment_type}" if comment_type
    i.underscore
  end


  def action_type
    i = "#{action}#{target_type}"
    i.underscore
  end
    
  def action_type?(current_type)
    i = "#{action}#{target_type.singular_class_name}"
    i.underscore
    i == current_type
  end
  
  def user
    target.user
  end

  def posted_date
    target.created_at
  end

  def downcase_type
    target.type.to_s.downcase
  end

end
