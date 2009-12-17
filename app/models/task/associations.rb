class Task
  belongs_to :task_list,  :counter_cache => true
  belongs_to :page
  belongs_to :assigned, :class_name => 'Person'
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
end