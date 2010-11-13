class TeamboxData
  # Note:
  # Internally the import is just a mass creation of objects using hashes of
  # teambox data properties. Importers for each different dump are required to
  # convert their representations to teambox data. 
  
  def unserialize_basecamp(object_maps, opts={})
    # xml dump format:
    # account/projects/project
    # ../attachment-categories/attachment-category
    # ../post-categories/post-category
    # ../milestones/milestone   [as task list?]
    # ../todo-lists/todo-list
    #    ../todo-items/todo-item
    # time-entries/time-entry   [comments]
    # posts/post [conversations]
    #   ../comments/comment [comments]
    # participants/person [people]
    
    import_data = metadata_basecamp(true)
    unserialize_teambox(import_data, object_maps, opts)
  end
  
  def metadata_basecamp(with_project_data=false)
    firm_members = []
    
    organization_list = ([data['account']['firm']] + data['account']['clients']).map do |firm|
      firm_members += firm['people']
      people = firm['people'].map do |person|
        {'user_id' => person['id']}
      end
      
      compat_name = firm['name'].first
      compat_name = compat_name.length < 4 ? (compat_name + '____') : compat_name
      
      {'id' => firm['id'],
       'name' => compat_name,
       'permalink' => PermalinkFu.escape(compat_name, Organization),
       'time_zone' => firm['time_zone_id'],
       'members' => people}
    end
    
    user_list = firm_members.map do |person|
      {'id' => person['id'],
       'first_name' => person['first_name'],
       'last_name' => person['last_name'] || '.',
       'email' => person['email_address'],
       'username' => person['name'].scan(/[A-Za-z0-9]+/).join(''),
       'created_at' => person['created_at']}
    end
    
    firm_user_ids = user_list.map{|u|u['id']}
    
    project_list = data['account']['projects'].map do |project|
      compat_name = project['name'].first
      compat_name = compat_name.length < 4 ? (compat_name + '____') : compat_name
      
      base = {'id' => project['id'],
       'organization_id' => data['account']['firm']['id'],
       'name' => compat_name,
       'permalink' => PermalinkFu.escape(compat_name, Organization),
       'archived' => project['status'] == 'active' ? false : true,
       'created_at' => project['created_on'],
       'owner_user_id' => user_list.first['id']}
      base['people'] = Array(project['participants']['person']).map do |participant|
        {'id' => participant,
          'user_id' => participant,
          'role' => firm_user_ids.include?(participant) ? Person::ROLES[:admin] : Person::ROLES[:participant]}
      end
      
      if with_project_data
        base['conversations'] = project['posts'].map do |post|
          {}.tap do |conversation|
            conversation.merge!({
              'name' => post['title'],
              'user_id' => post['author_id'],
              'created_at' => post['posted_on'],
              'simple' => false
            })
            first_post = {'body' => post['body'],
                          'created_at' => post['posted_on'],
                          'user_id' => post['author_id']}
            first_posts = first_post['body'].blank? ? [] : [first_post]
            conversation['comments'] = first_posts + post['comments'].map do |comment|
              {'body' => comment['body'],
               'created_at' => comment['created_at'],
               'user_id' => comment['author_id']}
            end
          end
        end
        
        base['task_lists'] = project['todo_lists'].map do |list|
          {}.tap do |task_list|
            task_list.merge!({
              'name' => list['name'].first,
              'user_id' => user_list.first['id'],
              'created_at' => project['created_on']
            })
            task_list['tasks'] = list['todo_items'].map do |list_item|
              task_status = if list_item['completed']
                :resolved
              else
                :open
              end
              
              {}.tap do |task|
                task.merge!({
                  'name' => list_item['content'],
                  'position' => list_item['position'],
                  'created_at' => list_item['created_at'],
                  'user_id' => list_item['creator_id'],
                  'status' => Task::STATUSES[task_status],
                  'due_on' => list_item['due_at']})
                task['assigned_id'] = list_item['responsible_party_id'] if list_item['responsible_party_type'] == 'Person'
                task['completed_at'] = (list_item['completed_at']||Time.now) if list_item['completed']
                task['comments'] = list_item['comments'].map do |comment|
                  {'body' => comment['body'],
                   'created_at' => comment['created_at'],
                   'user_id' => comment['author_id']}
                end
              end
            end
          end
        end
        
        base['task_lists'] << {}.tap do |task_list|
          task_list.merge!({
            'name' => 'Milestones',
            'user_id' => user_list.first['id'],
            'created_at' => project['created_on']
          })
          task_list['tasks'] = project['milestones'].map do |milestone|
            {}.tap do |task|
              task_status = if milestone['completed']
                :resolved
              else
                :open
              end           
              task.merge!({
                'name' => milestone['title'],
                'created_at' => milestone['created_on'],
                'user_id' => milestone['creator_id'],
                'status' => Task::STATUSES[task_status],
                'due_on' => milestone['deadline']})
              task['assigned_id'] = milestone['responsible_party_id'] if milestone['responsible_party_type'] == 'Person'
              task['completed_at'] = (milestone['completed_at']||Time.now) if milestone['completed']
              task['comments'] = milestone['comments'].map do |comment|
                {'body' => comment['body'],
                 'created_at' => comment['created_at'],
                 'user_id' => comment['author_id']}
              end
            end
          end
        end
      end
      
      base
    end
    
    {'users' => user_list,
      'projects' => project_list,
      'organizations' => organization_list}
  end
end