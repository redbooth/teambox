class TaskList < RoleRecord
  include Immortal

  include Watchable

  attr_accessible :name, :start_on, :finish_on

  concerned_with :validation,
                 :initializers,
                 :scopes,
                 :associations,
                 :callbacks

  before_save :ensure_date_order
  
  def self.from_pivotal_tracker(activity)
    unless activity and activity[:stories] and activity[:stories][:story]
      raise ArgumentError, "no Tracker story given"
    end
    
    story = activity[:stories][:story]
    
    task_list = self.find_by_name("Pivotal Tracker") || self.create! { |new_list|
      new_list.user = new_list.project.user if new_list.project
      new_list.name = "Pivotal Tracker"
      yield new_list if block_given?
    }
    
    author = task_list.project.users.detect { |u| u.name == activity[:author] }  
    
    task = task_list.tasks.from_pivotal_tracker(story[:id]).first || task_list.tasks.build { |new_task|
      new_task.name = "#{story[:name]} [PT#{story[:id]}]"
      new_task.user = author || task_list.user
    }

    task.update_from_pivotal_tracker(author, activity)
    return task
  end

  def to_s
    name
  end

  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
  end

  define_index do
    where "`task_lists`.`deleted` = 0"

    indexes name, :sortable => true
    has project_id, created_at, updated_at
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
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :watchers => Array.wrap(watchers_ids),
      :comments_count => comments_count,
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    base[:start_on] = start_on.to_s(:db) if start_on
    base[:finish_on] = finish_on.to_s(:db) if finish_on
    base[:completed_at] = completed_at.to_s(:db) if completed_at
    
    if Array(options[:include]).include? :tasks
      base[:tasks] = tasks.map {|t| t.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :thread_comments
      base[:first_comment] = first_comment.to_api_hash(options)  if first_comment
      base[:recent_comments] = recent_comments.map{|c|c.to_api_hash(options)}
    elsif !Array(options[:include]).include?(:comments)
      base[:first_comment_id] = first_comment.try(:id)
      base[:recent_comment_ids] = recent_comments.map{|c|c.id}
    end
    
    if Array(options[:include]).include? :comments
      base[:comments] = comments.map {|c| c.to_api_hash(options)}
    end
    
    base
  end

  private
    def ensure_date_order
      if start_on && finish_on && start_on > finish_on
        self.start_on, self.finish_on = finish_on, start_on
      end
    end
end