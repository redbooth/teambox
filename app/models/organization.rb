class Organization < ActiveRecord::Base
  has_many :projects #, :dependent => :destroy
  has_many :memberships

  has_many :users, :through => :memberships
  has_many :admins, :through => :memberships, :source => :user, :conditions => {'memberships.role' => Membership::ROLES[:admin]}
  has_many :participants, :through => :memberships, :source => :user, :conditions => {'memberships.role' => Membership::ROLES[:participant]}

  validates_length_of     :name, :minimum => 4

  validates_presence_of   :permalink
  validates_uniqueness_of :permalink, :case_sensitive => false
  validates_length_of     :permalink, :minimum => 4
  validates_exclusion_of  :permalink, :in => %w(www help support mail pop smtp ftp)

  before_validation_on_create :check_permalink
  
  attr_accessible :name, :permalink, :description

  def add_member(user_id, role=Membership::ROLES[:admin])
    user_id = user_id.id if user_id.is_a? User
    role = Membership::ROLES[role] if role.is_a? Symbol
    membership = memberships.new(:user_id => user_id.to_i, :role => role.to_i)
    membership.save
  end

  def name
    read_attribute(:name) || "Undefined"
  end
  
  def to_s
    name
  end

  def to_param
    permalink
  end

  def users_in_projects
    projects.collect { |p| p.users }.flatten.uniq
  end

  # External users are simply involved in some project of the organization
  def external_users
    users_in_projects - users
  end

  def is_admin?(user)
    memberships.find_by_user_id(user.id).try(:role) == Membership::ROLES[:admin]
  end

  def is_participant?(user)
    memberships.find_by_user_id(user.id).try(:role) == Membership::ROLES[:participant]
  end

  protected

  def check_permalink
    if permalink.blank?
      self.permalink = name.parameterize.to_s
    end
  end

end
