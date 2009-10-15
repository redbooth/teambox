# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Project < ActiveRecord::Base
  belongs_to :user # project owner

  has_many :people # people invited to the project
  has_many :users, :through => :people, :order => 'updated_at desc'

  has_many :task_lists, :conditions => { :page_id => nil }
  has_many :tasks
  has_many :invitations, :order => 'created_at DESC'
  has_many :conversations, :order => 'created_at DESC'
  has_many :pages, :order => 'created_at DESC'
  has_many :comments, :order => 'created_at DESC'
  has_many :uploads
  has_many :activities, :order => 'created_at DESC'
  
  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :permalink, :case_sensitive => false
  validates_format_of :permalink, :with => /^[a-z0-9_\-\.]{2,}$/

  validates_presence_of :user         # A project _needs_ an owner
  validates_associated :people        # And will only accept valid people
  
  attr_accessible :name, :permalink
  
  has_permalink :name
  
  def owner?(u)
    user = u
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
  
  def log_activity(target,action,creator_id=nil)
    creator_id = target.user_id unless creator_id
    Activity.log(self,target,action,creator_id)
  end
  
  def add_user(user,source_user=nil)
    unless Person.exists? :user_id => user.id, :project_id => self.id      
      source_user = user if source_user.nil?
      
      person = self.people.new(:user_id => user.id,:source_user_id => source_user.id)
      person.save
      log_activity(person,'create',person)
    end
  end

  def remove_user(user)
    person = Person.find_by_user_id_and_project_id user.id, self.id
    
    if person
      person.destroy
      log_activity(person,'delete')
    end
  end

  def after_create
    add_user(user)
  end
  
  def to_param
    permalink
  end
  
end