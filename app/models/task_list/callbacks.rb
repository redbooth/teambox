class TaskList
  def before_save
    unless self.position
      first_task_list = self.project.task_lists.first(:select => 'position')
      if first_task_list
        last_position = first_task_list.position
        self.position = last_position.nil? ? 1 : last_position.succ
      else
        self.position = 0
      end
    end
  end

  def after_create
    self.move_to_top
    self.project.log_activity(self,'create')
  end

end