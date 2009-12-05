# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Project < ActiveRecord::Base

  include GrabName
  
  acts_as_paranoid
  concerned_with :validation, :initializers, :roles

  belongs_to :user # project owner

  has_many :people, :dependent => :destroy # people invited to the project
  has_many :users, :through => :people, :order => 'updated_at desc'

  has_many :task_lists, :conditions => { :page_id => nil }, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :invitations, :order => 'created_at DESC', :dependent => :destroy
  has_many :conversations, :order => 'created_at DESC', :dependent => :destroy
  has_many :pages, :order => 'created_at DESC', :dependent => :destroy
  has_many :comments, :order => 'created_at DESC', :dependent => :destroy
  has_many :uploads, :dependent => :destroy
  has_many :activities, :order => 'created_at DESC', :dependent => :destroy

  has_permalink :name

  attr_accessible :name, :permalink  
  
  def self.grab_name_by_permalink(permalink)
    e = self.find_by_permalink(permalink,:select => 'name')
    e = e.nil? ? '' : e.name
  end
  
  def after_create
    self.add_user self.user
  end

  def log_activity(target, action, creator_id=nil)
    creator_id = target.user_id unless creator_id
    Activity.log(self, target, action, creator_id)
  end
  
  def add_user(user, source_user=nil)
    unless Person.exists? :user_id => user.id, :project_id => self.id
      source_user_id = source_user.id if source_user
      self.people.create(:user_id => user.id, :source_user_id => source_user_id)
    end
  end
  
  def remove_user(user)
    if person = Person.find_by_user_id_and_project_id(user.id, self.id)
      person.destroy

      user.recent_projects.delete self.id
      user.save!      
    end
  end

  def after_create
    add_user(user)
  end
  
  def to_param
    permalink
  end

  def task_lists_assigned_to(user)
    task_lists.unarchived.inject([]) do |t, task_list|
      person = people.find_by_user_id(user.id)
      t << task_list if task_list.tasks.count(:conditions => { :assigned_id => person.id }) > 0
      t
    end
  end

  def after_comment(comment)
    notify_new_comment(comment)
  end

  def notify_new_comment(comment)
    self.users.each do |user|
      if user != comment.user and user.notify_mentions and " #{comment.body} ".match(/\s@#{user.login}\W/i)
        Emailer.deliver_notify_comment(user, self, comment)
      end
    end
  end

  # Optimized way of getting activities for one or more project.
  # Can limit the number of records and page.
  def self.get_activities_for(projects, limit, after = nil)
    if after
      conditions = ["project_id IN (?) AND id < ?", Array(projects).collect{ |p| p.id }, after ]
    else
      conditions = ["project_id IN (?)", Array(projects).collect{ |p| p.id } ]
    end
    Activity.find(:all, :conditions => conditions,
                        :order => 'created_at DESC', # could be faster to use 'id DESC'
                        :limit => limit)
  end
  
  def get_recent(model_class, limit = 5)
    model_class.find(:all, :conditions => ["project_id = ?", id],
                           :order => 'created_at DESC',
                           :limit => limit)
  end
  
end