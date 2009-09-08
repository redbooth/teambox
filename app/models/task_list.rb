class TaskList < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :page
  
  has_many :tasks, :order => 'position'
  has_many :comments, :as => :target, :order => 'created_at DESC'
  
  validates_length_of :name, :minimum => 3
  
  attr_accessible :name
  
  def new_task(user,task)
    
    self.tasks.new(task) do |task|
      task.user_id = user.id
      task.project_id = self.project.id
    end
    
  end
  
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
  
  def after_create
    self.project.log_activity(self,'add')
  end
  
end