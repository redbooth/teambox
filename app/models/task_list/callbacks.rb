class TaskList
  before_create :init_list
  after_create :log_create
  
  def init_list
    unless self.position
      self.position = 0
      project.task_lists.each do |t|
        t.increment!(:position) unless t == self
      end
    end
  end

  def log_create
    self.project.log_activity(self,'create')
  end

end