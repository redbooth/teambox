require 'digest/sha1'

class Invitation < RoleRecord
  include Immortal
  belongs_to :invited_user, :class_name => 'User'

  validate :valid_user?
  validate :valid_role?
  validate :user_already_invited?
  validate :email_valid?
  
  attr_reader :user_or_email
  attr_accessor :is_silent
  attr_accessible :user_or_email, :role, :membership, :invited_user

  before_create :generate_token
  before_save :copy_user_email, :if => :invited_user
  after_create :auto_accept, :send_email

  scope :pending_projects, :conditions => ['project_id IS NOT ?', nil]

  # Reserved so invitations can be sent for other targets, in addition to Project
  def target
    project
  end

  def user_or_email=(value)
    self.invited_user = User.find_by_username_or_email(value)
    self.email = value unless self.invited_user
    @user_or_email = value
  end
  
  def accept(current_user)
    if target.is_a? Project
      target.organization.add_member(current_user, membership)
      project.add_user(current_user, {:role => role || 3, :source_user => user})
    elsif target.is_a? Organization
      target.add_member(current_user, membership)
    end
  end
  
  def editable?(user)
    project.admin?(user) or self.user_id == user.id or self.invited_user_id == user.id
  end

  def to_api_hash(options = {})
    base = {
      :id => id,
      :user_id => user_id,
      :invited_user_id => invited_user_id,
      :role => role,
      :project => {
        :permalink => project.permalink,
        :name => project.name
      }
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    base
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end

  protected

  def valid_user?
    @errors.add(:base, 'Must belong to a valid user') if user.nil? or user.deleted?
  end
  
  def valid_role?
    @errors.add(:base, 'Not authorized') if target.is_a?(Project) and user and !target.admin?(user)
  end
  
  def user_already_invited?
    return if invited_user.nil?
    if project and Person.exists?(:project_id => project_id, :user_id => invited_user.id)
      @errors.add :user_or_email, 'is already a member of the project'
    elsif Invitation.exists?(:project_id => project_id, :invited_user_id => invited_user.id)
      @errors.add :user_or_email, 'already has a pending invitation'
    end
  end

  def email_valid?
    return if invited_user
    if valid_email?(email)
      # One final check: do we have an invite for this email?
      if Invitation.exists?(:project_id => project_id, :email => email)
        @errors.add :user_or_email, 'already has a pending invitation'
      end
    else
      @errors.add :user_or_email, 'is not a valid username or email'
    end
  end

  def generate_token
    self.token ||= ActiveSupport::SecureRandom.hex(20)
  end

  def auto_accept
    self.accept(invited_user) if belongs_to_organization?
  end

  def send_email
    return if @is_silent
    if invited_user
      if belongs_to_organization?
        Emailer.send_email :project_membership_notification, self.id
        self.destroy
      else
        Emailer.send_email :project_invitation, self.id
      end
    else
      Emailer.send_email :signup_invitation, self.id
    end
  end
  
  if Rails.env.production? and respond_to? :handle_asynchronously
    handle_asynchronously :send_email 
  end
  
  def copy_user_email
    self.email ||= invited_user.email
  end

  def belongs_to_organization?
    invited_user and target.respond_to?(:organization) and target.organization.try(:is_user?, invited_user)
  end

  protected

    def valid_email?(value)
      EmailValidator.check_address(value)
    end

end
