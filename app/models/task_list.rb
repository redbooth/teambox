class TaskList < ActiveRecord::Base

  include Watchable

  belongs_to :user
  belongs_to :project
  belongs_to :page
  
  has_many :tasks, :order => 'position', :dependent => :destroy
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
  
  validates_length_of :name, :minimum => 3
  
  attr_accessible :name

  def before_save
    if position.nil?
      last_position = self.project.task_lists.find(:first,
        :order => 'position DESC',
        :limit => 1)
      
      if last_position.nil?
        self.position = 1
      else
        self.position = last_position.position + 1
      end 
    end
  end

  def before_save
    if position.nil?
      last_position = self.task_list.tasks.find(:first,
        :order => 'position DESC',
        :limit => 1)
      
      if last_position.nil?
        self.position = 1
      else
        self.position = last_position.position + 1
      end
      
    end
  end
  
  def owner?(u)
    user == u
  end
  
  def after_create
    self.project.log_activity(self,'create')
  end
  
end