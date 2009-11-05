class Task < ActiveRecord::Base
  include GrabName
  include Watchable

  default_scope :order => 'created_at DESC'
  
  belongs_to :project
  belongs_to :user
  belongs_to :task_list
  belongs_to :page

  belongs_to :assigned, :class_name => 'Person'
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
  belongs_to :assigned, :class_name => 'User'
  
  acts_as_list :scope => :task_list
  acts_as_paranoid
    
  attr_accessible :name, :assigned_id, :status

  STATUSES = ['new','open','hold','resolved','rejected']

  def self.status(n)
    STATUSES.index(n)
  end

  def before_save
    if position.nil?
      puts "-------|||||| #{self.task_list.tasks}"
      last_position = self.task_list.tasks.first(:select => 'position')
      self.position = last_position.nil? ? 1 : last_position.position.succ
    end
  end
  
  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
    Comment.destroy_all   :target_id => self.id, :target_type => self.class.to_s
  end

  def assigned?(u)
    assigned.user.id = u.id unless assigned.nil?
  end
  
  def owner?(u)
    user == u
  end
  
end
