class TaskList < RoleRecord

  include Watchable

  acts_as_list :scope => :project
  attr_accessible :name, :start_on, :finish_on

  concerned_with :validation,
                 :initializers,
                 :scopes,
                 :associations,
                 :callbacks

  before_save :ensure_date_order

  def notify_new_comment(comment)
    self.watchers.each do |user|
      if user != comment.user and user.notify_task_lists
        Emailer.send_with_language(:notify_task_list, user.locale, user, self.project, self) # deliver_notify_task_list
      end
    end
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

  def to_api_hash(options = {})
    base = {
      :id => id,
      :project_id => project_id,
      :user_id => user_id,
      :name => name,
      :position => position,
      :archived => archived,
      :created_at => created_at.to_s(:db),
      :updated_at => updated_at.to_s(:db),
      :watchers => Array.wrap(watchers_ids)
    }
    
    base[:start_on] = start_on.to_s(:db) if start_on
    base[:finish_on] = finish_on.to_s(:db) if finish_on
    base[:completed_at] = completed_at.to_s(:db) if completed_at
    
    if Array(options[:include]).include? :tasks
      base[:tasks] = tasks.map {|t| t.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :comments
      base[:comments] = comments.map {|c| c.to_api_hash(options)}
    end
    
    base
  end

  def to_json(options = {})
    to_api_hash(options).to_json
  end

  private
  
    def ensure_date_order
      if start_on && finish_on && start_on > finish_on
        self.start_on, self.finish_on = finish_on, start_on
      end
    end
end