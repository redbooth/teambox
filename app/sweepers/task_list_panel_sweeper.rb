class TaskListPanelSweeper < ActionController::Caching::Sweeper
  observe Task, TaskList, Comment

  def after_save(record)
    if expire_cache?(record)
      expire_task_list_panel(record)
    end
  end

  private
    def expire_task_list_panel(record)
      task_list = task_list_for_record(record)
      # Rails.logger.info("XXX fragment Task list is #{task_list.inspect}")
      if task_list
        I18n.backend.available_locales.each do |lang|
          cache_key = task_list.cache_key_for_sidebar_panel(lang)
          if fragment_exist?(cache_key)
            expire_fragment(cache_key)
          end
        end
      end
    end

    def expire_cache?(record)
      # if the name of task list changes, it has to be reflected in the task list panel
      # a new task or a task with a changed name must appear on the task list panel
      # new comment on a Task changes the task count on the task list panel
      task_list_name_changed = record.is_a?(TaskList) and (not record.new_record?)
      task_changed = record.is_a?(Task)
      new_comment_on_task = record.is_a?(Comment) and record.target.is_a?(Task) and record.new_record?
      task_list_name_changed or task_changed or new_comment_on_task
    end

    def task_list_for_record(record)
      case record
      when TaskList then record
      when Task     then record.task_list
      when Comment  then
         tgt = record.target
         tgt.task_list if tgt.respond_to?(:task_list)
      end
    end
end