class Organization < ActiveRecord::Base
  include Immortal
  include Metadata
  extend Metadata::Defaults

  has_permalink :name
  has_many :projects #, :dependent => :destroy
  has_many :memberships, :dependent => :destroy

  has_many :users, :through => :memberships
  has_many :admins, :through => :memberships, :source => :user, :conditions => {'memberships.role' => Membership::ROLES[:admin]}
  has_many :participants, :through => :memberships, :source => :user, :conditions => {'memberships.role' => Membership::ROLES[:participant]}

  validates_length_of     :name, :minimum => 4

  validates_presence_of   :permalink
  validates_uniqueness_of :permalink, :case_sensitive => false, :scope => :deleted
  validates_uniqueness_of :domain, :case_sensitive => false, :allow_nil => true, :allow_blank => true
  validates_length_of     :permalink, :minimum => 4
  validates_exclusion_of  :permalink, :in => %w(www help support mail pop smtp ftp guide)
  validates_format_of     :permalink, :with => /^[\w\_\-]+$/

  validate :ensure_unicity_for_community_version, :on => :create, :unless => :is_example

  before_destroy :prevent_if_projects
  
  attr_accessor :is_example
  attr_accessible :name, :permalink, :description, :logo, :settings

  LogoSizes = {
    :square   => [96, 96],
    :top      => [134, 36]
  }

  has_attached_file :logo, 
    :url  => "/logos/:id/:style.png",
    :path => (Teambox.config.amazon_s3 ? "logos/:id/:style.png" : ":rails_root/public/logos/:id/:style.png"),
    :s3_protocol => (Teambox.config.secure_logins ? 'https' : 'http'),
    :styles => LogoSizes.each_with_object({}) { |(name, size), all|
        all[name] = ["%dx%d>" % [size[0], size[1]], :png]
      }

  validates_attachment_size :logo, :less_than => 5.megabytes, :if => :has_logo?
  validates_attachment_content_type :logo,
    :content_type => %w[image/jpeg image/pjpeg image/png image/x-png image/gif]

  def add_member(user_id, role=Membership::ROLES[:admin])
    user_id = user_id.id if user_id.is_a? User
    role = Membership::ROLES[role] if role.is_a? Symbol
    return true if role == Membership::ROLES[:external]
    member = memberships.find_by_user_id(user_id)
    if member.nil?
      member = memberships.new(:role => role.to_i)
      member.user_id = user_id.to_i
      member.save
    else
      member.update_attribute(:role, role)
    end
  end

  def to_s
    name
  end

  def to_param
    permalink
  end
  
  def self.find_by_id_or_permalink(param)
    if param.to_s =~ /^\d+$/
      find_by_id(param)
    else
      find_by_permalink(param)
    end
  end

  def users_in_projects
    User.find(:all, :joins => :people, :conditions => {:people => {:project_id => project_ids}}).uniq
  end

  # External users are simply involved in some project of the organization
  def external_users
    (users_in_projects - users).sort_by {|u| u.first_name}
  end

  def is_admin?(user)
    memberships.admin?.count(:conditions => {:user_id => user.id} ) > 0
  end

  def is_participant?(user)
    memberships.participant?.count(:conditions => {:user_id => user.id} ) > 0
  end

  def is_user?(user)
    !!memberships.find_by_user_id(user.id)
  end

  def has_logo?
    !!logo.original_filename
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :name => name,
      :permalink => permalink,
      :language => language,
      :time_zone => time_zone,
      :domain => domain,
      :description => description,
      :logo_url => logo.url,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:db)
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :members
      base[:members] = memberships.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :projects
      base[:projects] = projects.map {|p| p.to_api_hash(options)}
    end
    
    base
  end

  protected

    def ensure_unicity_for_community_version
      if Teambox.config.community && new_record?
        errors.add(:base, "Can't have more than one organization") if Organization.count > 0
      end
    end

    def prevent_if_projects
      projects.empty?
    end

end

Organization.default_settings = {
    'colours' => {
      'header_bar' => '78ACD7',
      'links' => '259BAD',
      'highlight' => 'fff9da',
      'text' => '333',
      'link_hover' => 'df5249'
    }
  }

