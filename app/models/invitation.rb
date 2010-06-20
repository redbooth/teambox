require 'digest/sha1'

class Invitation < RoleRecord
  belongs_to :user
  belongs_to :project
  belongs_to :group
  belongs_to :invited_user, :class_name => 'User'
  
  attr_reader :user_or_email
  attr_accessible :user_or_email, :user, :project, :role, :group
  
  validate :check_invite

  def target
    project || group
  end
  
  def check_invite
    if project.nil? and group.nil?
      @errors.add_to_base('Must belong to a project or group')
      return
    end
    @errors.add_to_base('Must belong to a valid user') if user.nil? or user.deleted? or !(target.admin?(user))
    
    # Check user
    check_user = invited_user
    unless check_user.nil?
      if group and group.has_member?(check_user)
        @errors.add :user_or_email, 'is already a member of the group'
        return
      elsif project and Person.exists?(:project_id => project_id, :user_id => check_user.id)
        @errors.add :user_or_email, 'is already a member of the project'
        return
      elsif Invitation.exists?(:project_id => project_id, :invited_user_id => check_user.id)
        @errors.add :user_or_email, 'already has a pending invitation'
        return
      end
    end
    
    # Check email (for non-existent users)
    if check_user.nil?
      if valid_email?(email)
        # One final check: do we have an invite for this email?
        if Invitation.exists?(:project_id => project_id, :email => email)
          @errors.add :user_or_email, 'already has a pending invitation'
        end
      else
        @errors.add :user_or_email, 'is not a valid username or email'
      end
    end
  end
  
  def user_or_email=(value)
    user_to_invite = User.find_by_username_or_email value
    
    if user_to_invite
      self.email = user_to_invite.email
    else
      self.email = value
    end
    
    self.invited_user = user_to_invite
    @user_or_email = value
  end
  
  def send_email
    if invited_user
      if project
        Emailer.deliver_project_invitation self
      else
        Emailer.deliver_group_invitation self
      end
    else
      if project
        Emailer.deliver_signup_invitation self
      else
        Emailer.deliver_signup_group_invitation self
      end
    end
  end
  
  def accept(current_user)
    if target.class == Project
      person = self.project.people.new(
        :user => current_user,
        :role => self.role || 3,
        :source_user => self.user)
      person.save
    else
      target.add_user(current_user)
    end
  end
  
  def editable?(user)
    (project || group).admin?(user) or self.user_id == user.id or self.invited_user_id == user.id
  end

  def before_save
    self.token ||= ActiveSupport::SecureRandom.hex(20)
  end
  
  def after_save
    send_email
  end
end