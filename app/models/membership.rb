class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization

  validates_presence_of :user, :organization
  validates_inclusion_of :role, :in => [10,20,30]

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

end
