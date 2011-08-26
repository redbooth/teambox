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
      if Array(options[:include]).include? :tasks
        tasks.to_xml(options.merge({ :skip_instruct => true }))
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
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    base[:start_on] = start_on.to_s(:db) if start_on
    base[:finish_on] = finish_on.to_s(:db) if finish_on
    base[:completed_at] = completed_at.to_s(:db) if completed_at
    
    task_as_ids = Array(options[:include]).include? :task_ids
    task_key = task_as_ids ? :task_ids : :tasks
    if Array(options[:include]).include? :tasks
      base[task_key] = task_as_ids ? task_ids : tasks.map {|t| t.to_api_hash(options)}
    elsif Array(options[:include]).include? :unarchived_tasks
      base[task_key] = task_as_ids ? unarchived_task_ids : tasks.unarchived.map {|t| t.to_api_hash(options)}
    elsif Array(options[:include]).include? :archived_tasks
      base[task_key] = task_as_ids ? archived_task_ids : tasks.archived.map {|t| t.to_api_hash(options)}
    end
    
    base
  end
end