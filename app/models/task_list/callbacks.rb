class TaskList
  def before_create
    unless self.position
      self.position = 0
      project.task_lists.each do |t|
        t.increment!(:position) unless t == self
      end
    end
  end

  def after_create
    self.project.log_activity(self,'create')
  end

end