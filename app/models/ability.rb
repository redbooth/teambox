class Ability
  include CanCan::Ability

  def initialize(user)
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
    
    can :update, [Task, Conversation] do |object|
      object.project.editable?(user)
    end
    
    can :destroy, [Task, Conversation] do |object|
      object.project.admin?(user)
    end
    
    can :converse, Project do |project|
      project.commentable?(user)
    end
  end
end
