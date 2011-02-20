class TeamboxData
  def unserialize_teambox(dump, object_maps, opts={})
    ActiveRecord::Base.transaction do
      @object_map = {
        'User' => {},
        'Organization' => {}
      }.merge(object_maps)
      
      @processed_objects = {}
      @imported_users = @object_map['User'].clone
      @organization_map = @object_map['Organization'].clone
      
      @processed_objects[:user] = []
      
      @users = dump['users'].map do |udata|
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
        @processed_objects[:user] << user.id
        import_log(user, "#{udata['username']} -> #{user_name}")
      end.compact
      
      @processed_objects[:organization] = []
      @organizations = dump['organizations'].map do |organization_data|
        organization_name = @organization_map[organization_data['permalink']] || organization_data['permalink']
        organization = Organization.find_by_permalink(organization_name)
        
        if user and organization and !organization.is_admin?(user)
          raise(Exception, "#{user} needs to be an admin of #{organization}")
        end
        
        if organization.nil? and opts[:create_organizations]
          organization = unpack_object(Organization.new, organization_data, []) if organization.nil?
          organization.permalink = organization_name if organization.nil?
          organization.save!
        end
        
        raise(Exception, "Organization #{organization} could not be resolved") if organization.nil?
        
        @organization_map[organization_data['id']] = organization
        @processed_objects[:user] << organization.id
        
        Array(organization_data['members']).each do |member_data|
          org_user = resolve_user(member_data['user_id'])
          organization.add_member(org_user, member_data['role']) unless organization.is_user?(org_user)
        end
      end
      
      @processed_objects[:project] = []
      @imported_people = {}
      @projects = dump['projects'].map do |project_data|
        @project = Project.find_by_permalink(project_data['permalink'])
        if @project
          project_data['permalink'] += "-#{rand}"
        end
        @project = unpack_object(Project.new, project_data, [])
        @project.is_importing = true
        @project.import_activities = []
        @project.user = resolve_user(project_data['owner_user_id'])
        @project.organization = @organization_map[project_data['organization_id']] || @project.user.organizations.first
        @project.save!
        
        import_log(@project)
      
        Array(project_data['people']).each do |person_data|
          @project.add_user(resolve_user(person_data['user_id']), 
                            :role => person_data['role'],
                            :source_user => user ? user : resolve_user(person_data['source_user_id']))
          @imported_people[person_data['id']] = @project.people.last
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
        
          Array(task_list_data['tasks']).each do |task_data|
            # Tasks automatically create comments, so we need to be careful!
            task = unpack_object(task_list.tasks.build, task_data)
            
            # To determine the initial state of the task, we need to look at the first comment
            if task_data['comments'] && task_data['comments'].length > 0
              first_comment = task_data['comments'][0]
              task.status = first_comment['previous_status'] if first_comment['previous_status']
              task.assigned_id = resolve_person(first_comment['previous_assigned_id']).id if first_comment['previous_assigned_id']
              task.due_on = first_comment['previous_due_on'] if first_comment['previous_due_on']
            end
            
            task.updating_date = task.created_at
            task.updating_user = task.user
            task.save!
            
            import_log(task)
            unpack_task_comments(task, task_data['comments'])
            
            task.updating_date = task.created_at
            task.updating_user = task.user
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
        
        @processed_objects[:project] << @project.id
        @project
      end
      
      self.projects = @processed_objects[:project]
      
      # Restore all activities
      @projects.map(&:import_activities).flatten.sort_by{|a|a[:date]}.each do |activity|
        if activity[:target_type] == Comment
          # touch activity related to that comment's thread
          Activity.last(:conditions => ["target_type = ? AND target_id = ?",
                                        activity[:comment_target_type], activity[:comment_target_id]]).try(:touch)
        end
        act = Activity.new(
          :project_id => activity[:project].id,
          :target_id => activity[:target_id],
          :target_type => activity[:target_class].to_s,
          :action => activity[:action],
          :user_id => activity[:creator_id],
          :comment_target_type => activity[:comment_target_type],
          :comment_target_id => activity[:comment_target_id])
        act.created_at = activity[:date]
        act.updated_at = activity[:date]
        act.save!
      end
      
      @projects.each do |project|
        project.is_importing = false
        project.log_activity(self, 'create', user.id) if user
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
      if obj.class != Project and obj.respond_to? :user_id
        throw Exception.new("#{object.class.to_s} '#{object.to_s}' does not have a valid user") if data['user_id'].nil?
        obj.user_id = resolve_user(data['user_id']).id if data['user_id']
      end
      if obj.respond_to? :assigned_id
        obj.assigned_id = resolve_person(data['assigned_id']).try(:id) if data['assigned_id']
      end
      obj.watchers_ids = data['watchers'].map{|u| @imported_users[u].try(:id)}.compact if data['watchers']
      obj.created_at = data['created_at'] if data['created_at']
      obj.updated_at = data['updated_at'] if data['updated_at']
    end
  end
  
  def unpack_comments(obj, comments)
    return if comments.nil?
    comments.each do |comment_data|
      comment = unpack_object(@project.comments.build, comment_data)
      comment.is_importing = true
      comment.assigned_id = resolve_person(comment_data['assigned_id']).try(:id) if data['assigned_id']
      comment.target = obj
      comment.save!
      import_log(comment)
    end
  end
  
  def unpack_task_comments(task, comments)
    # comments on tasks work differently. We need to UPDATE the task!
    return if comments.nil?
    comments.each do |comment_data|
      comment = unpack_object(task.comments.build, comment_data)
      comment.is_importing = true
      comment.assigned_id = resolve_person(comment_data['assigned_id']).try(:id) if data['assigned_id']
      task.updating_user = comment.user
      task.updating_date = comment.created_at
      task.save!
      import_log(comment)
    end
  end
end