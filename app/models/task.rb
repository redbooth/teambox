class Task < ActiveRecord::Base

  include Watchable

  belongs_to :project
  belongs_to :user
  belongs_to :task_list
  belongs_to :page

  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
  belongs_to :assigned, :class_name => 'User'
  
  attr_accessible :name

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
  
  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
    Comment.destroy_all   :target_id => self.id, :target_type => self.class.to_s
  end

  def owner?(u)
    user == u
  end
  
end
