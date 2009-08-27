class TaskList < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  has_many :tasks, :order => 'position'
  
  validates_length_of :name, :minimum => 3
  
  attr_accessible :name
  
  def new_task(user,task)
    
    self.tasks.new(task) do |task|
      task.user_id = user.id
      task.project_id = self.project.id
    end
    
  end
end