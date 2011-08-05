class TeamboxData
  attr_writer :data
  
  def serialize(organizations, projects)
    users = []
    base = {
      :account => {
        :projects => projects.map{|p|
          users += Person.with_deleted.where(:project_id => p.id).includes(:user).map(&:user)
          users.compact!
          
          p.to_api_hash(:include => [
          :tasks,
          :task_lists,
          :comments,
          :conversations,
          :invitations,
          :pages,
          :people,
          :slots,
          :rel_object,
          :uploads])
        }
      }
    }
    
    if organizations && !organizations.empty?
      users += organizations.map{|o| o.memberships.includes(:user).map(&:user)}.flatten
      base[:account][:organizations] = organizations.map{|o| o.to_api_hash(:include => [:members, :projects])}
    end
    base[:account][:users] = users.compact.map{|u| u.attributes}
    
    base
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
        u[user['login']] = user
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
    @ids_to_users ||= users.inject({}){|hash,u| hash[u['id']] = u}
  end

  def resolve_user(id)
    return nil if id.nil?
    user = @imported_users[id]
    if !user
      need_user = ids_to_users[id] || {'login' => id}
      add_unprocessed_object("users","User '#{need_user['login']}' not present. Please map it to an existing user or create it.")
    end
    user
  end
  
  def resolve_person(id)
    return nil if id.nil?
    @imported_people[id]
  end
  
  def import_log(object, remark="")
    if object
      logger.warn "[IMPORT] Imported #{object}[id: #{object.id}] (#{remark})"
    else
      add_unprocessed_object("nil class", "Trace: #{caller.join("\n")}")
    end
  end

  def add_unprocessed_object(model, msg="")
    if model.kind_of?(ActiveRecord::Base)
      @unprocessed_objects[model.class.table_name] = {:model => model, :errors => model.errors.full_messages}
    else
      @unprocessed_objects[model] = {:model => nil, :errors => [msg]}
    end
  end

  def attempt_save(model, old_data=nil)
    begin
      if model
        logger.info "[IMPORT]  Attempting save! on model: #{model.inspect}"
        model.save!

        #Record id mapping
        if old_data && old_data['id']
          log_mapping(model.class.name, old_data['id'], model.id)
        end

        yield if block_given?
      else
        add_unprocessed_object("nil class", "Trace: #{caller.join("\n")}")
      end
    rescue ActiveRecord::ActiveRecordError => err
      #Reraise StatementInvalid errors
      if err.is_a?(ActiveRecordError::StatementInvalid)
        raise err
      end

      logger.warn "[IMPORT] Caught exception: #{err.message} model: #{model.inspect} errors: #{model ? model.errors.full_messages.inspect : ''} trace: #{err.backtrace[0..10].join("\n")}"
      add_unprocessed_object(model)
      false
    end
  end
  
  def self.import_from_file(name, user_map, opts={})
    data = File.open(name, 'r') do |file|
      opts[:format] == 'basecamp' ? Hash.from_xml(file.read) : ActiveSupport::JSON.decode(file.read)
    end
    TeamboxData.new.tap{|d| d.service = opts[:format]||'teambox'; d.data = data}.unserialize(user_map, opts)
  end
  
  def self.export_to_file(projects, organizations, name)
    data = TeamboxData.new.serialize(organizations, projects)
    File.open(name, 'w') { |file| file.write data.to_json }
  end
end
