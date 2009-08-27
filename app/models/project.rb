class Project < ActiveRecord::Base
  belongs_to :user
  has_many :task_lists
  has_many :tasks
  has_many :conversations, :order => 'created_at DESC'
  has_many :pages, :order => 'created_at DESC'
  has_many :comments, :as => :target, :order => 'created_at DESC'
  
  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :permalink
  validates_format_of :permalink, :with => /^[a-z0-9_\-\.]{2,}$/
  
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
  
  def to_param
    permalink
  end
  
end