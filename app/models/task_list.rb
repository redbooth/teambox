class TaskList < ActiveRecord::Base
  include GrabName
  include Watchable

  default_scope :order => 'created_at DESC'
  
  belongs_to :user
  belongs_to :project
  belongs_to :page
  
  has_many :tasks, :order => 'position', :dependent => :destroy
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy

  acts_as_list :scope => :project
  acts_as_paranoid    
  attr_accessible :name

  validates_length_of :name, :minimum => 3
  
  def before_save
    if self.position.nil?
      first_task_list = self.project.task_lists.first(:select => 'position')
      if first_task_list.nil?
        self.position = 0
      else
        last_position = first_task_list.position
        self.position = last_position.nil? ? 1 : last_position.succ
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