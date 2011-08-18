require 'digest/sha1'

class Invitation < RoleRecord
  include Immortal
  belongs_to :invited_user, :class_name => 'User'

  validate :valid_user?
  validate :valid_role?
  validate :user_already_invited?

  attr_accessor :is_silent, :locale
  attr_accessible :role, :membership, :invited_user

  before_create :generate_token
  after_create :auto_accept, :send_email, :update_user_stats

  scope :pending_projects, :conditions => ['project_id IS NOT ?', nil]

  # for new style invites asking for name...
  attr_accessor :first_name, :last_name

  # Reserved so invitations can be sent for other targets, in addition to Project
  def target
    project
  end
  
  def user
    @user ||= user_id ? User.find_with_deleted(user_id) : nil
  end
  
  def accept(current_user)
    if target.is_a? Project
      target.organization.add_member(current_user, membership)
      project.add_user(current_user, {:role => role || 3, :source_user => user})

      # Notify the sender that the invitation has been accepted
      unless @autoaccepted
        Emailer.send_with_language :accepted_project_invitation, self.user.locale, current_user.id, self.id
      end
    elsif target.is_a? Organization
      target.add_member(current_user, membership)
    end
  end
  
  def editable?(user)
    project.admin?(user) or self.user_id == user.id or self.invited_user_id == user.id
  end
  
  def references
    refs = { :users => [user_id, invited_user_id], :projects => [project_id] }
    refs
  end

  def to_api_hash(options = {})
    base = {
      :id => id,
      :user_id => user_id,
      :invited_user_id => invited_user_id,
      :role => role,
      :membership => membership,
      :project => {
        :permalink => project.permalink,
        :name => project.name
      }
    }
    
    base[:invited_user] = invited_user.to_api_hash unless invited_user.nil?
    base[:type] = self.class.to_s if options[:emit_type]
    
    base
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end

  def send_email
    return if @is_silent or invited_user.nil?
    
    # Existing users
    if @autoaccepted
      # This notifies the user that he's now in a new project
      Emailer.send_with_language :project_membership_notification, invited_user.locale, self.id
    else
      # We ask the user to go to Teambox to accept the invite
      Emailer.send_with_language :project_invitation, invited_user.locale , self.id
    end
  end
  
  if Rails.env.production? and respond_to? :handle_asynchronously
    handle_asynchronously :send_email 
  end

  protected

  def valid_user?
    @errors.add(:base, 'Must belong to a valid user') if user.nil? or user.deleted? or invited_user.nil? or invited_user.deleted?
  end

  def valid_role?
    @errors.add(:base, 'Not authorized') if target.is_a?(Project) and user and !target.admin?(user)
  end

  def user_already_invited?
    return if invited_user.nil?
    if project and Person.exists?(:project_id => project_id, :user_id => invited_user.id)
      @errors.add :invited_user_id, 'is already a member of the project'
    elsif Invitation.exists?(:project_id => project_id, :invited_user_id => invited_user.id)
      @errors.add :invited_user_id, 'already has a pending invitation'
    end
  end

  def generate_token
    self.token ||= ActiveSupport::SecureRandom.hex(20)
  end

  # Autoaccept the invite if the user has this setting
  def auto_accept
    if invited_user.try(:auto_accept_invites)
      @autoaccepted = true
      self.accept(invited_user)
      self.destroy
    end
  end

  def update_user_stats
    user.increment_stat 'invites' if user
  end

end
