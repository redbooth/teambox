class TaskList
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
end