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

  validate :ensure_unicity_for_community_version, :on => :create

  before_validation_on_create :check_permalink
  
  attr_accessible :name, :permalink, :description, :logo

  LogoSizes = {
    :square   => [96, 96],
    :top      => [134, 36]
  }

  has_attached_file :logo, 
    :url  => "/logos/:id/:style.png",
    :path => (Teambox.config.amazon_s3 ? "logos/:id/:style.png" : ":rails_root/public/logos/:id/:style.png"),
    :styles => LogoSizes.each_with_object({}) { |(name, size), all|
        all[name] = ["%dx%d>" % [size[0], size[1]], :png]
      }

  #validates_attachment_presence :avatar, :unless => Proc.new { |user| user.new_record? }
  validates_attachment_size :logo, :less_than => 5.megabytes, :if => :has_logo?
  validates_attachment_content_type :logo,
    :content_type => %w[image/jpeg image/pjpeg image/png image/x-png image/gif]

  def add_member(user_id, role=Membership::ROLES[:admin])
    user_id = user_id.id if user_id.is_a? User
    role = Membership::ROLES[role] if role.is_a? Symbol
    membership = memberships.new(:user_id => user_id.to_i, :role => role.to_i)
    membership.save
  end
  
  def ensure_member(user_id, role=Membership::ROLES[:participant])
    user_id = user_id.id if user_id.is_a? User
    member = memberships.find_by_user_id(user_id)
    
    if member and member.role < role
      member.update_attribute(:role, role)
    else
      add_member(user_id, role)
    end
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

  def is_user?(user)
    !!memberships.find_by_user_id(user.id)
  end

  def has_logo?
    !!logo.original_filename
  end

  protected

    def check_permalink
      if permalink.blank?
        self.permalink = name.parameterize.to_s
      end
    end

    def ensure_unicity_for_community_version
      if Teambox.config.community && new_record?
        errors.add_to_base("Can't have more than one organization") if Organization.count > 0
      end
    end
end
