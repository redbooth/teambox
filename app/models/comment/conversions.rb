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
      :target_type => target_type
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if target.is_a? Task
      base[:assigned_id] = assigned_id
      base[:previous_assigned_id] = previous_assigned_id
      base[:previous_status] = previous_status
      base[:status] = status
    end
    
    if uploads.any?
      base[:uploads] = uploads.map {|u| u.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :users
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