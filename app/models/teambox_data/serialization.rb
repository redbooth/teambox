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
  
  def unserialize(object_maps, opts={})
    if service == 'basecamp'
      unserialize_basecamp(object_maps, opts)
    else
      unserialize_teambox({'users' => data['account']['users'],
                           'projects' => data['account']['projects'],
                           'organizations' => data['account']['organizations']}, 
                           object_maps, opts)
    end
  end
  
  # Generate metadata used for the frontend for mapping
  def metadata
    @metadata ||= if service == 'basecamp'
      # Calculate basic metadata from basecamp
      metadata_basecamp(false)
    elsif !data['account'].nil?
      {'users' => data['account']['users'],
        'projects' => data['account']['projects'],
        'organizations' => data['account']['organizations']}
    else
      {'users' => [],
        'projects' => [],
        'organizations' => []}
    end
  end
  
  def users
    metadata['users']
  end
  
  def users_lookup
    {}.tap do |u|
      metadata['users'].each do |user|
        u[user['username']] = user
      end
    end
  end
  
  def projects
    metadata['projects']
  end
  
  def organizations
    metadata['organizations']
  end
  
  def ids_to_users
    if @ids_to_users.nil?
      @ids_to_users ||= {}
      users.each{|u| @ids_to_users[u['id']] = u}
    else
      @ids_to_users
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
  
  def resolve_person(id)
    return nil if id.nil?
    @imported_people[id]
  end
  
  def import_log(object, remark="")
    Rails.logger.warn "Imported #{object} (#{remark})"
  end
  
  def self.import_from_file(name, user_map, opts={})
    data = File.open(name, 'r') do |file|
      opts[:format] == 'basecamp' ? Hash.from_xml(file.read) : ActiveSupport::JSON.decode(file.read)
    end
    TeamboxData.new.tap{|d| d.service = opts[:format]||'teambox'; d.data = data}.unserialize(user_map, opts)
  end
  
  def self.export_to_file(projects, users, organizations, name)
    data = TeamboxData.new.serialize(organizations, projects, users)
    File.open(name, 'w') { |file| file.write data.to_json }
  end
end