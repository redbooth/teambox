class Project

  def create_task_list(user,task_list)
    self.task_lists.create(task_list) do |task_list|
      task_list.user_id = user.id
    end
  end
  
  def create_task(user,task_list,task)
    self.tasks.create(task) do |task|
      task.user_id = user.id
      task.task_list_id = task_list.id
    end
  end

  def new_task_list(user,task_list)
    self.task_lists.new(task_list) do |task_list|
      task_list.user_id = user.id
    end
  end
  
  def new_task(user,task_list,task)
    self.tasks.new(task) do |task|
      task.user_id = user.id
      task.task_list_id = task_list.id
    end
  end
    
  def new_conversation(user,conversation)
    self.conversations.new(conversation) do |conversation|
      conversation.user_id = user.id
    end
  end

  def new_task_comment(task,comment={})
    self.comments.new(comment) do |comment|
      comment.project_id = self.id
      comment.status = task.status
      comment.target = task
    end
  end


  def new_comment(user, target, attributes)
    self.comments.new.tap { |comment|
      comment.user = user
      comment.target = target
      comment.attributes = attributes
    }
  end
  
  def new_page(user,page)
    self.pages.new(page) do |page|
      page.user_id = user.id
    end
  end
  
  def new_upload(user,target = nil)
    if target == nil
      self.uploads.new(:user_id => user.id)
    else
      self.uploads.new do |upload|
        upload.user_id = user.id
        upload.target = target
      end
    end
  end

end