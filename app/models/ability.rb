class Ability
  include CanCan::Ability
  
  def api_write?(user)
    user.current_token ? user.current_token.scope.include?(:write_projects) : true
  end
  
  def api_read?(user)
    user.current_token ? user.current_token.scope.include?(:read_projects) : true
  end
  
  def private_access?(user, object)
    (object && object.is_private) ? object.watcher_ids.include?(user.id) : true
  end

  def owner?(user, object)
    object.user == user
  end
  
  def last_admin_in_project?(person)
    person.role == Person::ROLES[:admin] && person.project.admins.length == 1
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
      api_write?(user) && project.commentable?(user) && private_access?(user, object)
    end
    
    can :watch, [Task, Conversation, Page] do |object|
      api_write?(user) && object.project.commentable?(user) && private_access?(user, object)
    end
    
    can :unwatch, [Task, Conversation, Page] do |object|
      api_write?(user) && (object.is_private == false || !object.required_watcher_ids.include?(user.id))
    end

    # Core object permissions
    
    can :update, [Conversation, Task, Page] do |object|
      api_write?(user) && object.editable?(user) && private_access?(user, object)
    end
    
    can :update, TaskList do |object|
      api_write?(user) && object.editable?(user)
    end
    
    can :update, Upload do |object|
      target = object.try(:comment).try(:target)
      api_write?(user) && object.editable?(user) && private_access?(user, target)
    end

    can :update, Folder do |object|
      api_write?(user) && (object.owner?(user) or object.project.admin?(user))
    end
    
    can :destroy, [Conversation, Task] do |object|
      api_write?(user) && (object.owner?(user) or object.project.admin?(user)) && private_access?(user, object)
    end
    
    can :destroy, Upload do |object|
      target = object.try(:comment).try(:target)
      api_write?(user) && (object.owner?(user) or object.project.admin?(user)) && private_access?(user, target)
    end

    can :destroy, Folder do |object|
      api_write?(user) && (object.owner?(user) or object.project.admin?(user))
    end
    
    can :destroy, [TaskList, Page] do |object|
      api_write?(user) && (object.owner?(user) or object.project.admin?(user))
    end

    can :destroy, AppLink do |object|
      api_write?(user) && owner?(user, object)
    end

    # Person permissions
    
    can :update, Person do |person|
      api_write?(user) && person.project.admin?(user) && !last_admin_in_project?(person)# && (person.user != user)
    end
    
    can :destroy, Person do |person|
      api_write?(user) && (person.user == user or person.project.admin?(user)) && !last_admin_in_project?(person)
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

    can :create_folders, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    can :reorder_objects, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    can :reorder_objects, Project do |project|
      api_write?(user) && project.editable?(user)
    end
    
    can :update, Project do |project|
      api_write?(user) && project.manage?(user)
    end
    
    can :destroy, Project do |project|
      api_write?(user) && project.manage?(user)
    end
    
    can :admin, Project do |project|
      api_write?(user) && project.admin?(user)
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
    
    can :update, User do |the_user|
      api_write?(user) && the_user.id == user.id
    end
    
    can :observe, User do |the_user|
      user.observable?(the_user)
    end
    
    # OAuth :read_projects show permission
    can :show, [Invitation, Membership, Organization, Person, Project, TaskList, User] do |object|
      api_read?(user)
    end
    
    can :show, Page do |object|
      api_read?(user) && private_access?(user, object)
    end
    
    can :show, [Divider, Note] do |object|
      api_read?(user) && private_access?(user, object.page)
    end
    
    can :show, [Conversation, Task] do |object|
      api_read?(user) && private_access?(user, object)
    end
    
    can :show, Comment do |object|
      api_read?(user) && private_access?(user, object.target)
    end
    
    can :show, Upload do |object|
      target = object.try(:comment).try(:target)
      api_read?(user) && private_access?(user, target)
    end
    
    can :show, Activity do |object|
      api_read?(user) && if object.is_private
        (object.comment_target||object.target).watcher_ids.include?(user.id)
      else
        true
      end
    end

    can :show, AppLink do |object|
      api_read?(user) && owner?(user, object)
    end

    can :update_privacy, [Conversation, Task] do |object|
      object.user_id == user.id
    end
    
  end
end
