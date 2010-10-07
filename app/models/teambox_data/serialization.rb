class TeamboxData
  attr_writer :data
  
  def serialize(organizations, projects, users)
    {
      :account => {
        :projects => projects.map{|p| p.to_api_hash(:include => [
          :tasks,
          :task_lists,
          :comments,
          :conversations,
          :invitations,
          :pages,
          :people,
          :slots,
          :rel_object,
          :uploads])},
        :users => users.map{|u| u.to_api_hash(:include => [:email])},
        :organizations => organizations.map{|o| o.to_api_hash(:include => [:members, :projects])}
      }
    }
  end
  
  def users
    data['account']['users']
  end
  
  def users_lookup
    {}.tap do |u|
      data['account']['users'].each do |user|
        u[user['username']] = user
      end
    end
  end
  
  def projects
    data['account']['projects']
  end
  
  def organizations
    data['account']['organizations']
  end
  
  def ids_to_users
    if @ids_to_users.nil?
      @ids_to_users ||= {}
      users.each{|u| @ids_to_users[u['id']] = u}
    else
      @ids_to_users
    end
  end
  
  def unserialize(object_maps, opts={})
    ActiveRecord::Base.transaction do
      dump = data['account']
      
      @unserialize_log = []
      
      @object_map = {
        'User' => {},
        'Organization' => {}
      }.merge(object_maps)
      
      @imported_users = @object_map['User']
      @organization_map = @object_map['Organization']
      @out_dump = []
      
      @users = users.map do |udata|
        user_name = @imported_users[udata['username']] || udata['username']
        user = User.find_by_login(user_name)
        if user.nil? and opts[:create_users]
          user = User.new(udata)
          user.login = udata['username']
          user.password = user.password_confirmation = udata['password'] || rand().to_s
          user.save!
        end
        
        raise(Exception, "User #{user} could not be resolved") if user.nil?
        
        @imported_users[udata['id']] = user
        import_log(user, "#{udata['username']} -> #{user_name}")
      end.compact
      
      @organizations = organizations.map do |organization_data|
        organization_name = @organization_map[organization_data['permalink']] || organization_data['permalink']
        organization = Organization.find_by_permalink(organization_name)
        
        if organization.nil? and opts[:create_organizations]
          organization = unpack_object(Organization.new, organization_data, []) if organization.nil?
          organization.permalink = organization_name if organization.nil?
          organization.save!
        end
        
        raise(Exception, "Organization #{organization} could not be resolved") if organization.nil?
        
        @organization_map[organization_data['id']] = organization
        
        Array(organization_data['members']).each do |member_data|
          organization.add_member(resolve_user(member_data['user_id']), member_data['role'])
        end
      end
      
      @projects = projects.map do |project_data|
        @project = Project.find_by_permalink(project_data['permalink'])
        if @project
          project_data['permalink'] += "-#{rand}"
        end
        @project = unpack_object(Project.new, project_data, ['user_id'])
        @project.user = resolve_user(project_data['owner_user_id'])
        @project.organization = @organization_map[project_data['organization_id']] || @project.user.organizations.first
        @project.save!
        
        import_log(@project)
      
        Array(project_data['people']).each do |person_data|
          @project.add_user(resolve_user(person_data['user_id']), 
                            :role => person_data['role'],
                            :source_user => resolve_user(person_data['source_user_id']))
        end
        
        # Note on commentable objects: callbacks may be invoked which may change their state. 
        # For now we will play dumb and re-assign all attributes after we have unpacked comments.
      
        Array(project_data['conversations']).each do |conversation_data|
          conversation = unpack_object(@project.conversations.build, conversation_data)
          conversation.is_importing = true
          conversation.save!
          import_log(conversation)
        
          unpack_comments(conversation, conversation_data['comments'])
          unpack_object(conversation, conversation_data).save!
        end
      
        Array(project_data['task_lists']).each do |task_list_data|
          task_list = unpack_object(@project.task_lists.build, task_list_data)
          task_list.save!
          import_log(task_list)
        
          unpack_comments(task_list, task_list_data['comments'])
        
          Array(project_data['tasks']).each do |task_data|
            task = unpack_object(task_list.tasks.build, task_data)
            task.save!
            import_log(task)
            unpack_comments(task, task_data['comments'])
            unpack_object(task, task_data).save!
          end
          
          unpack_object(task_list, task_list_data).save!
        end
      
        Array(project_data['pages']).each do |page_data|
          page = unpack_object(@project.pages.build, page_data)
          page.save!
          import_log(page)
        
          obj_type_map = {'Note' => :notes, 'Divider' => :dividers}
        
          Array(page_data['slots']).each do |slot_data|
            next if obj_type_map[slot_data['rel_object_type']].nil? # not handled yet
            rel_object = unpack_object(page.send(obj_type_map[slot_data['rel_object_type']]).build, slot_data['rel_object'])
            rel_object.updated_by = page.user
            rel_object.save!
            rel_object.page_slot.position = slot_data['position']
            rel_object.page_slot.save!
            import_log(rel_object)
          end
        end
      end
    end
  end
  
  def unpack_object(object, data, non_mass=[])
    object.tap do |obj|
      obj.attributes = data
      
      non_mass.each do |key|
        obj.send("#{key}=", data[key]) if data[key]
      end
      
      obj.project = @project if obj.respond_to? :project
      obj.user_id = resolve_user(data['user_id']).id if data['user_id']
      obj.watchers_ids = data['watchers'].map{|u| @imported_users[u].try(:id)}.compact if data['watchers']
      obj.created_at = data['created_at'] if data['created_at']
      obj.updated_at = data['updated_at'] if data['updated_at']
    end
  end
  
  def unpack_comments(obj, comments)
    return if comments.nil?
    comments.each do |comment_data|
      comment = unpack_object(@project.comments.build, comment_data)
      comment.target = obj
      comment.save!
      import_log(comment)
    end
  end
  
  def resolve_user(id)
    return nil if id.nil?
    user = @imported_users[id]
    if !user
      need_user = ids_to_users[id] || {'username' => id}
      throw Exception.new("User '#{need_user['username']}' not present. Please map it to an existing user or create it.")
    end
    user
  end
  
  def import_log(object, remark="")
    puts "Imported #{object} (#{remark})"
  end
  
  def self.import_from_file(name, user_map, opts={})
    ActionMailer::Base.perform_deliveries = false
    data = File.open(name, 'r') { |file| ActiveSupport::JSON.decode file.read }
    TeamboxData.new.tap{|d| d.data = data}.unserialize(user_map, opts)
  end
  
  def self.export_to_file(projects, users, organizations, name)
    data = TeamboxData.new.serialize(organizations, projects, users)
    File.open(name, 'w') { |file| file.write data.to_json }
  end
end