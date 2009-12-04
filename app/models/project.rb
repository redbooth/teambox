# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Project < ActiveRecord::Base
  include GrabName
  acts_as_paranoid
  
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
  
  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :permalink, :case_sensitive => false
  validates_format_of :permalink, :with => /^[a-z0-9_\-\.]{5,}$/

  validates_presence_of :user         # A project _needs_ an owner
  validates_associated :people        # And will only accept valid people
  
  validates_each :user, :on => :update do |record, attr, value|
    record.errors.add attr, "doesn't even belong to the project!" unless record.users.collect{ |u| u.id }.include? record.user.id
  end
  
  attr_accessible :name, :permalink
  
  has_permalink :name

  def task_lists_assigned_to(user)
    task_lists.unarchived.inject([]) do |t, task_list|
      person = people.find_by_user_id(user.id)
      t << task_list if task_list.tasks.count(:conditions => { :assigned_id => person.id }) > 0
      t
    end
  end
  
  def self.grab_name_by_permalink(permalink)
    e = self.find_by_permalink(permalink,:select => 'name')
    e = e.nil? ? '' : e.name
  end

  def owner?(u)
    user == u
  end
  
  def after_create
    self.add_user self.user
  end
  
  def new_task_list(user,task_list)
    self.task_lists.new(task_list) do |task_list|
      task_list.user_id = user.id
    end
  end
  
  def new_conversation(user,conversation)
    self.conversations.new(conversation) do |conversation|
      conversation.user_id = user.id
    end
  end

  def new_comment(user,target,comment)
    self.comments.new(comment) do |comment|
      comment.project_id = self.id
      comment.user_id = user.id
      comment.target = target
    end
  end
  
  def new_page(user,page)
    self.pages.new(page) do |page|
      page.user_id = user.id
    end
  end
  
  def new_upload(user,target = nil)
    if target == nil
      self.uploads.new(:user_id => user.id)
    else
      self.uploads.new do |upload|
        upload.user_id = user.id
        upload.target = target
      end
    end
  end
  
  def log_activity(target, action, creator_id=nil)
    creator_id = target.user_id unless creator_id
    Activity.log(self, target, action, creator_id)
  end
  
  def add_user(user, source_user=nil)
    unless Person.exists? :user_id => user.id, :project_id => self.id
      source_user ||= user
      self.people.create(:user_id => user.id, :source_user_id => source_user.id)
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

  def admin?(user)
    if p = people.find(:first, :conditions => {:user_id => user.id})
      p.role == 3 || p.owner?
    end
  end
  
  def observer?(user)
    if p = people.find(:first, :conditions => {:user_id => user.id})
      p.role == 0 && p.owner? == false
    else
      false
    end
  end
  
  def editable?(user)
    if p = people.find(:first, :conditions => {:user_id => user.id})
      p.owner? || p.role > 0
    else
      false
    end
  end

  
  def recent_conversations(get = 5)
    conversations[0,get]
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
  
end