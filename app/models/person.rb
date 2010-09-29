# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Person < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :source_user, :class_name => 'User'

  acts_as_paranoid
  
#  validates_uniqueness_of :user, :scope => :project
  validates_presence_of :user, :project   # Make sure they both exist and are set
  validates_inclusion_of :role, :in => 0..3

  serialize :permissions

  ROLES = {:observer => 0, :commenter => 1, :participant => 2, :admin => 3}
  PERMISSIONS = [:view,:edit,:delete,:all]
  
  named_scope :admins, :conditions => "role = #{ROLES[:admin]}"
  
  named_scope :from_unarchived, :joins => :project,
    :conditions => ['projects.archived = ?', false]
  
  named_scope :by_login, lambda { |login|
    {:include => :user, :conditions => {'users.login' => login}}
  }

  def owner?
    project.owner?(user)
  end

  def role_name
    ROLES.index(role)
  end

  def to_s
    name
  end

  def name
    user.name
  end
  
  def short_name
    user.short_name
  end
  
  def login
    user.login
  end
  
  def after_create
    # for a new project, we log create_project, not create_person
    project.log_activity(self, 'create', user_id) unless project.user == user
    # promote the project owner to admin
    update_attribute :role, ROLES[:admin] if project.user == user
  end
  
  def after_destroy
    project.log_activity(self, 'delete')
    user.remove_recent_project(project)
  end
  
  def self.users_from_projects(projects)
    user_ids = Person.find(:all, :conditions => {:project_id => projects.map(&:id)}).map(&:user_id).uniq
    User.find(:all, :conditions => {:id => user_ids}, :select => 'id, login, first_name, last_name').sort_by(&:name)
  end
  
  def self.user_names_from_projects(projects)
    project_ids = Array.wrap(projects).map(&:id)
    connection.select_rows(<<-SQL)
      SELECT people.project_id, users.login, users.first_name, users.last_name
      FROM people
      INNER JOIN projects ON projects.id = people.project_id
      INNER JOIN users ON users.id = people.user_id
      WHERE people.project_id IN (#{project_ids.join(',')})
        AND people.deleted_at IS NULL
      ORDER BY users.login
    SQL
  end
  
  def user
    User.find_with_deleted(user_id)
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.person :id => id do
      xml.tag! 'user-id', user.id
      xml.tag! 'username', user.login
      xml.tag! 'role', role
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :user_id => user.id,
      :username => user.login,
      :role => role,
      :user => user.to_api_hash
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    base
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end
end