class TeamboxData
  attr_accessor :data
  attr_accessor :ready
  attr_accessor :import_data
  attr_writer :map_data
  
  serialize :project_ids
  serialize :map_data
  
  TYPE_LOOKUP = {:import => 0, :export => 1}
  TYPE_CODES = TYPE_LOOKUP.invert
  
  def user_map
    map = map_data['User']
    if map.nil?
      known_map = {}
      known_users = user.organizations.map{|o| o.users + o.users_in_projects }.flatten.compact.each do |user|
        known_map[user.login] = user
      end
      
      map = {}
      users.each do |user|
        map[user['username']] = known_map[user['username']].login
      end
      @map_data['User'] = map
    end
    map
  end
  
  def user_map=(value)
    map_data['User'] = value
  end
  
  def target_organization
    map_data['target_organization']
  end
  
  def target_organization=(value)
    map_data['target_organization'] = value
  end
  
  def map_data
    @map_data ||= {}
  end
  
  def type_name
    TYPE_CODES[type_id]
  end
  
  def type_name=(value)
    self.type_id = TYPE_LOOKUP[value.to_sym]
  end
  
  def projects_to_export=(value)
    self.project_ids = Array(value).map(&:to_i).compact
  end
  
  def projects_to_export
    Project.find(:all, :conditions => {:id => project_ids})
  end
  
  def organizations_to_export
    Organization.find(:all, :conditions => {:projects => {:id => project_ids}}, :joins => [:projects])
  end
  
  def users_to_export
    organizations_to_export.map{|o| o.users + o.users_in_projects }.flatten.compact
  end
  
  def data
    if @data.nil? and type_name == :import
      begin
        File.open("/tmp/#{processed_data_file_name}") do |f|
          @data = ActiveSupport::JSON.decode f.read
        end
      rescue
        nil
      end
    else
      @data
    end
  end
end