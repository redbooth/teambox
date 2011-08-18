class Project
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.project :id => id do
      xml.tag! 'name', name
      xml.tag! 'permalink', permalink
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'archived', archived
      xml.tag! 'owner-user-id', user_id
      xml.people :count => people.size do
        for person in people
          person.to_xml(options.merge({ :skip_instruct => true, :root => :person }))
        end
      end
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :organization_id => organization_id,
      :name => name,
      :permalink => permalink,
      :archived => archived,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :archived => archived,
      :owner_user_id => user_id
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :project_people
      base[:people] = people.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :project_task_lists
      base[:task_lists] = task_lists.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :project_invitations
      base[:invitations] = invitations.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :project_pages
      base[:pages] = pages.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :project_uploads
      base[:uploads] = uploads.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :project_conversations
      base[:conversations] = conversations.map {|p| p.to_api_hash(options)}
    end
    
    base
  end
end