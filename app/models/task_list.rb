class TaskList < RoleRecord
  acts_as_list :scope => :project
  attr_accessible :name, :start_on, :finish_on

  serialize :watchers_ids

  concerned_with :validation,
                 :initializers,
                 :scopes,
                 :associations,
                 :callbacks

  def notify_new_comment(comment)
    self.watchers.each do |user|
      if user != comment.user and user.notify_task_lists
        Emailer.send_with_language(:notify_task_list, user.language, user, self.project, self) # deliver_notify_task_list
      end
    end
    self.sync_watchers
  end

  def to_s
    name
  end

  def user
    User.find_with_deleted(user_id)
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.task_list :id => id do
      xml.tag! 'project-id',      project_id
      xml.tag! 'user-id',         user_id
      xml.tag! 'name',            name
      xml.tag! 'position',        position
      xml.tag! 'archived',        archived
      xml.tag! 'start-on',        start_on.to_s(:db) if start_on
      xml.tag! 'finish-on',       finish_on.to_s(:db) if finish_on
      xml.tag! 'created-at',      created_at.to_s(:db)
      xml.tag! 'updated-at',      updated_at.to_s(:db)
      xml.tag! 'completed-at',    completed_at.to_s(:db) if completed_at
      xml.tag! 'watchers',        Array(watchers_ids).join(',')
      if Array(options[:include]).include? :tasks
        tasks.to_xml(options.merge({ :skip_instruct => true }))
      end
      if Array(options[:include]).include? :comments
        comments.to_xml(options.merge({ :skip_instruct => true }))
      end
    end
  end
end