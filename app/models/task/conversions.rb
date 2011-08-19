class Task
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.task :id => id do
      xml.tag! 'project-id',      project_id
      xml.tag! 'user-id',         user_id
      xml.tag! 'name',            name
      xml.tag! 'position',        position
      xml.tag! 'comments-count',  comments_count
      xml.tag! 'assigned-id',     assigned_id
      xml.tag! 'status',          status
      xml.tag! 'due-on',          due_on.to_s(:db) if due_on
      xml.tag! 'urgent',          urgent?
      xml.tag! 'created-at',      created_at.to_s(:db)
      xml.tag! 'updated-at',      updated_at.to_s(:db)
      xml.tag! 'completed-at',    completed_at.to_s(:db) if completed_at
      xml.tag! 'watchers',        Array.wrap(watcher_ids).join(',')
      unless Array(options[:include]).include? :tasks
        task_list.to_xml(options.merge({ :skip_instruct => true }))
      end
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :project_id => project_id,
      :task_list_id => task_list_id,
      :user_id => user_id,
      :name => name,
      :position => position,
      :comments_count => comments_count,
      :assigned_id => assigned_id,
      :status => status,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :watchers => Array.wrap(watcher_ids),
      :is_private => is_private
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    base[:due_on] = due_on.to_s(:db) if due_on
    base[:urgent] = urgent?
    base[:completed_at] = completed_at.to_s(:db) if completed_at
    
    if Array(options[:include]).include? :task_list
      base[:task_list] = task_list.to_api_hash(options)
    end
    
    if Array(options[:include]).include? :assigned
      base[:assigned] = assigned.to_api_hash(:include => :user) if assigned
    end
    
    if Array(options[:include]).include? :thread_comments
      base[:first_comment] = first_comment.to_api_hash(options)  if first_comment
      base[:recent_comments] = recent_comments.map{|c|c.to_api_hash(options)}
    elsif !Array(options[:include]).include?(:comments)
      base[:first_comment_id] = first_comment.try(:id)
      base[:recent_comment_ids] = recent_comments.map{|c|c.id}
    end
    
    if Array(options[:include]).include? :user
      base[:user] = {
        :username => user.login,
        :first_name => user.first_name,
        :last_name => user.last_name,
        :avatar_url => user.avatar_or_gravatar_url(:thumb)
      }
    end
    
    base
  end
end
