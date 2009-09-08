# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Project < ActiveRecord::Base
  belongs_to :user # project owner

  has_many :people # people invited to the project
  has_many :users, :through => :people, :order => 'updated_at desc'

  has_many :task_lists, :conditions => { :page_id => nil }
  has_many :tasks
  has_many :invitations
  has_many :conversations, :order => 'created_at DESC'
  has_many :pages, :order => 'created_at DESC'
  has_many :comments, :as => :target, :order => 'created_at DESC'
  has_many :uploads
  has_many :activities, :order => 'created_at DESC'
  
  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :permalink
  validates_format_of :permalink, :with => /^[a-z0-9_\-\.]{2,}$/

  validates_presence_of :user         # A project _needs_ and owner
  validates_associated :people        # An will only accept valid people
  
  attr_accessible :name, :permalink
  
  has_permalink :name
  
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
  
  def log_activity(target,action)
    Activity.log(self,target,action)
  end
  
  def add_person(user)
    person = self.people.new(:user_id => user.id)
    person.save
    log_activity(person,'add')
  end

  def after_create
    add_person(user)
  end
  
  def to_param
    permalink
  end
  
end