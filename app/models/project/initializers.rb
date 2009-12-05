class Project

  def new_task_list(user,task_list)
    self.task_lists.new(task_list) do |task_list|
      task_list.user_id = user.id
    end
  end
  
  def new_conversation(user,conversation)
    self.conversations.new(conversation) do |conversation|
      conversation.user_id = user.id
    end
  end

  def new_comment(user,target,comment)
    self.comments.new(comment) do |comment|
      comment.project_id = self.id
      comment.user_id = user.id
      comment.target = target
    end
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