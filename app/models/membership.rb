class Membership < ActiveRecord::Base
  ROLES = {:external => 10, :participant => 20, :admin => 30}

  belongs_to :user
  belongs_to :organization

  scope :admin?, :conditions => {'memberships.role' => ROLES[:admin]}
  scope :participant?, :conditions => {'memberships.role' => ROLES[:participant]}

  validates_presence_of :user, :organization
  validates_inclusion_of :role, :in => [10,20,30]
  validates_uniqueness_of :user_id, :scope => :organization_id
  
  before_validation :set_default_role, :on => :create

  before_destroy :validate_presence_of_at_least_one_admin, :if => lambda { |membership|
    membership.role_name == :admin and !membership.organization.marked_for_destruction?
  }
  before_update :validate_presence_of_at_least_one_admin, :if => lambda { |membership|
    membership.role_changed? and membership.role_was == ROLES[:admin]
  }

  attr_accessor :user_or_email
  
  attr_accessible :role

  # Roles are..
  #   30 for an admin. Can modify the organization, manage users and access any project.
  #   20 for a participant. Can create projects inside the organization, and only access projects where he's been invited to.
  #   10 for an external user. Can only access projects where he's been invited to. (NOT stored in database)

  def set_default_role
    self.role ||= ROLES[:admin]
  end

  def validate_presence_of_at_least_one_admin
    if organization.admins.count == 1
      errors.add(:base, "An organization need at least one administrator")
      false
    end
  end
  
  def references
    { :users => [user_id], :organization => [organization_id] }
  end

  def role_name
    ROLES.index(role)
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :user_id => user_id,
      :organization_id => organization_id,
      :role => role,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:db)
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :user
      base[:user] = {
        :username => user.login,
        :first_name => user.first_name,
        :last_name => user.last_name,
        :avatar_url => user.avatar_or_gravatar_url(:thumb)
      }
    end
    
    base
  end
end
