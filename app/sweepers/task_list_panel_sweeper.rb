class TaskListPanelSweeper < ActionController::Caching::Sweeper
  observe Task, TaskList, Comment

  def after_save(record)
    if expire_cache?(record)
      %w(en es fr de).each do |lang|
        cache_key = task_list_for_record(record).cache_key_for_sidebar_panel(lang)
        expire_fragment(cache_key)
      end
    end
  end

  private
    def expire_cache?(record)
      # if the name of task list changes, it has to be reflected on the task list panel
      # a new task or a task with a changed name must appear on the task list panel
      # new comment on a Task changes the task count on the task list panel
      task_list_name_changed = record.is_a?(TaskList) and (not record.new_record?)
      task_changed = record.is_a?(Task)
      new_comment_on_task = record.is_a?(Comment) and record.target.is_a?(Task) and record.new_record?
      task_list_name_changed or task_changed or new_comment_on_task
    end

    def task_list_for_record(record)
      if record.is_a?(TaskList)
        record
      elsif record.is_a?(Task)
        record.task_list
      else
        record.target.task_list
      end
    end
end