class Ability
  include CanCan::Ability
  
  def api_write?(user)
    user.current_token ? user.current_token.scope.include?(:write_projects) : true
  end
  
  def api_read?(user)
    user.current_token ? user.current_token.scope.include?(:read_projects) : true
  end

  def initialize(user)
    
    # Comment & commentable permissions
    
    can :update, Comment do |comment|
      return false unless api_write?(user)
      comment.user_id == user.id and
        Time.now < 15.minutes.since(comment.created_at)
    end
    
    can :destroy, Comment do |comment|
      return false unless api_write?(user)
      comment.project.admin?(user) or
        ( comment.user_id == user.id and
          Time.now < 15.minutes.since(comment.created_at) )
    end
    
    can :comment, [Task, Conversation] do |object, project|
      project ||= object.project
      api_write?(user) && project.commentable?(user)
    end
    
    can :watch, [Task, Conversation, Page] do |object|
      api_write?(user) && object.project.commentable?(user)
    end
    
    # Core object permissions
    
    can :update, [Conversation, Task, TaskList, Page, Upload] do |object|
      api_write?(user) && object.editable?(user)
    end
    
    can :destroy, [Conversation, Task, TaskList, Page, Upload] do |object|
      api_write?(user) && (object.owner?(user) or object.project.admin?(user))
    end
    
    # Person permissions
    
    can :update, Person do |person|
      api_write?(user) && (person.project.admin?(user) and !person.project.owner?(person.user))
    end
    
    can :destroy, Person do |person|
      api_write?(user) && (!person.project.owner?(person.user) and (person.user == user or person.project.admin?(user)))
    end
    
    # Invite permissions
    
    can :update, Invitation do |invitation|
      api_write?(user) && invitation.editable?(user)
    end
    
    can :destroy, Invitation do |invitation|
      api_write?(user) && invitation.editable?(user)
    end
    
    # Project permissions
    
    can :converse, Project do |project|
      api_write?(user) && project.commentable?(user)
    end
    
    can :make_tasks, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    can :make_task_lists, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    can :make_pages, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    can :upload_files, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    can :reorder_objects, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    # TODO: remove, this should be consolidated into the organization
    can :transfer, Project do |project|
      api_write?(user) && project.admin?(user)
    end
    
    can :update, Project do |project|
      api_write?(user) && (project.owner?(user) or project.admin?(user))
    end
    
    can :destroy, Project do |project|
      api_write?(user) && project.owner?(user)
    end
    
    can :admin, Project do |project|
      api_write?(user) && (project.owner?(user) or project.admin?(user))
    end
    
    # Organization permissions
    
    can :admin, Organization do |organization|
      api_write?(user) && organization.is_admin?(user)
    end
    
    # User permissions
    
    can :create_project, User do |the_user|
      api_write?(user) && the_user.can_create_project?
    end
    
    can :admin, User do |the_user|
      api_write?(user) && user.id == the_user.id
    end
    
    can :observe, User do |the_user|
      user.observable?(the_user)
    end
    
    # OAuth :read_projects show permission
    can :show, [Comment, Divider, Invitation, Membership, Note, Organization, Page, Person, Project, TaskList, Upload, User] do |object|
      api_read?(user)
    end
    
    can :show, [Conversation, Task] do |object|
      api_read?(user) && (object.is_private ? object.watcher_ids.include?(user.id) : true)
    end
    
    can :show, Activity do |object|
      api_read?(user) && if object.is_private
        (object.comment_target||object.target).watcher_ids.include?(user.id)
      else
        true
      end
    end
    
  end
end
