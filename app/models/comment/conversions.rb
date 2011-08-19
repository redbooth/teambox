class Comment
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.comment :id => id do
      xml.tag! 'body', body
      xml.tag! 'body-html', body_html
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'user-id', user_id
      unless Array(options[:include]).include? :comments
        xml.tag! 'project-id', project_id
        xml.tag! 'target-id', target.id
        xml.tag! 'target-type', target.class
      end
      if target.is_a? Task
        xml.tag! 'assigned-id', assigned_id
        xml.tag! 'previous-assigned-id', previous_assigned_id
        xml.tag! 'previous-status', previous_status
        xml.tag! 'status', status
      end
      if uploads.any?
        xml.files :count => uploads.size do
          for upload in uploads
            upload.to_xml(options.merge({ :skip_instruct => true }))
          end
        end
      end
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :body => body,
      :body_html => body_html,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :user_id => user_id,
      :project_id => project_id,
      :target_id => target_id,
      :target_type => target_type,
      :hours => hours,
      :upload_ids => upload_ids,
      :google_doc_ids => google_doc_ids
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if target_type == 'Task'
      base[:assigned_id] = assigned_id
      base[:previous_assigned_id] = previous_assigned_id
      base[:previous_status] = previous_status
      base[:status] = status
      base[:due_on] = due_on
      base[:previous_due_on] = previous_due_on
      base[:urgent] = urgent
      base[:previous_urgent] = previous_urgent
    end
    
    if Array(options[:include]).include?(:uploads) && uploads.any?
      base[:uploads] = uploads.map {|u| u.to_api_hash(options)}
    end

    if Array(options[:include]).include?(:google_docs) && google_docs.any?
      base[:google_docs] = google_docs.map {|u| u.to_api_hash(options)}
    end

    if Array(options[:include]).include?(:assigned)
      base[:assigned] = assigned
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
