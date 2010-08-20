class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization

  validates_presence_of :user, :organization
  validates_inclusion_of :role, :in => [10,20,30]
  validates_uniqueness_of :user_id, :scope => :organization_id

  ROLES = {:external => 10, :participant => 20, :admin => 30}

  attr_accessor :user_or_email

  # Roles are..
  #   30 for an admin. Can modify the organization, manage users and access any project.
  #   20 for a participant. Can create projects inside the organization, and only access projects where he's been invited to.
  #   10 for an external user. Can only access projects where he's been invited to.

  def before_validation_on_create
    self.role ||= ROLES[:admin]
  end

  def role_name
    ROLES.index(role)
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :user_id => user_id,
      :user => user.to_api_hash,
      :organization_id => organization_id,
      :role => role,
      :created_at => created_at.to_s(:db),
      :updated_at => updated_at.to_s(:db)
    }
    
    base
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end

end
