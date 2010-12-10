class Ability
  include CanCan::Ability

  def initialize(user)
    
    # Comment & commentable permissions
    
    can :update, Comment do |comment|
      comment.user_id == user.id and
        Time.now < 15.minutes.since(comment.created_at)
    end
    
    can :destroy, Comment do |comment|
      comment.project.admin?(user) or
        ( comment.user_id == user.id and
          Time.now < 15.minutes.since(comment.created_at) )
    end
    
    can :comment, [Task, Conversation] do |object, project|
      project ||= object.project
      project.commentable?(user)
    end
    
    can :watch, [Task, Conversation] do |object|
      object.project.commentable?(user)
    end
    
    # Core object permissions
    
    can :update, [Conversation, Task, TaskList, Page, Upload] do |object|
      object.editable?(user)
    end
    
    can :destroy, [Conversation, Task, TaskList, Page, Upload] do |object|
      object.owner?(user) or object.project.admin?(user)
    end
    
    # Person permissions
    
    can :update, Person do |person|
      person.project.admin?(user) and !person.project.owner?(person.user)
    end
    
    can :destroy, Person do |person|
      !person.project.owner?(person.user) and (person.user == user or person.project.admin?(user))
    end
    
    # Invite permissions
    
    can :update, Invitation do |invitation|
      invitation.editable?(user)
    end
    
    can :destroy, Invitation do |invitation|
      invitation.editable?(user)
    end
    
    # Project permissions
    
    can :converse, Project do |project|
      project.commentable?(user)
    end
    
    can :make_tasks, Project do |project|
      project.editable?(user)
    end
    
    can :make_task_lists, Project do |project|
      project.editable?(user)
    end
    
    can :make_pages, Project do |project|
      project.editable?(user)
    end
    
    can :upload_files, Project do |project|
      project.editable?(user)
    end
    
    can :reorder_objects, Project do |project|
      project.editable?(user)
    end
    
    # TODO: remove, this should be consolidated into the organization
    can :transfer, Project do |project|
      project.admin?(user)
    end
    
    can :update, Project do |project|
      project.owner?(user) or project.admin?(user)
    end
    
    can :destroy, Project do |project|
      project.owner?(user)
    end
    
    can :admin, Project do |project|
      project.owner?(user) or project.admin?(user)
    end
    
    # Organization permissions
    
    can :admin, Organization do |organization|
      organization.is_admin?(user)
    end
    
    # User permissions
    
    can :create_project, User do |the_user|
      the_user.can_create_project?
    end
    
    can :admin, User do |the_user|
      user.id == the_user.id
    end
    
    can :observe, User do |the_user|
      user.observable?(the_user)
    end
  end
end
