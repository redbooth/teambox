class Project < ActiveRecord::Base
  belongs_to :user
  has_many :task_lists
  has_many :conversations
  
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
  
  def to_param
    permalink
  end
  
end