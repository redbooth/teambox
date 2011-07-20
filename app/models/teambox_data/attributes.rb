class TeamboxData
  attr_accessor :data
  attr_accessor :import_data
  attr_writer :map_data
  
  serialize :project_ids
  serialize :processed_objects
  serialize :map_data
  
  TYPE_LOOKUP = {:import => 0, :export => 1}
  TYPE_CODES = TYPE_LOOKUP.invert
  
  IMPORT_STATUS_NAMES = [:uploading, :mapping, :pre_processing, :processing, :imported]
  IMPORT_STATUSES = IMPORT_STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }
  
  EXPORT_STATUS_NAMES = [:selecting, :pre_processing, :processing, :exported]
  EXPORT_STATUSES = EXPORT_STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }
  
  def user_map
    map = map_data['User']
    if map.nil?
      known_map = {}
      known_users = user.organizations.map{|o| o.users + o.users_in_projects }.flatten.compact.each do |user|
        known_map[user.login] = user
      end
      
      map = {}
      users.each do |user|
        map[user['username']] = known_map[user['username']].try(:login)
      end
      map_data['User'] = map
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
    if self[:map_data]
      self[:map_data]
    else
      self[:map_data] = {}
    end
  end
  
  def type_name
    TYPE_CODES[type_id]
  end
  
  def type_name=(value)
    self.type_id = TYPE_LOOKUP[value.to_sym]
  end
  
  def status_name
    type_id == 0 ? IMPORT_STATUS_NAMES[status] : EXPORT_STATUS_NAMES[status]
  end
  
  def status_name=(value)
    self.status = type_id == 0 ? IMPORT_STATUSES[value] : EXPORT_STATUSES[value]
  end
  
  def projects=(value)
    self.project_ids = Array(value).map(&:to_i).compact
  end
  
  def project_ids=(value)
    self[:project_ids] = Array(value).map(&:to_i).compact
  end
  
  def projects
    if user
      Project.find(:all, :conditions => {:id => project_ids, :organization_id => user.admin_organization_ids})
    else
      Project.find(:all, :conditions => {:id => project_ids})
    end
  end
  
  def organizations_to_export
    if user
      Organization.find(:all, :conditions => {:projects => {:id => project_ids, :organization_id => user.admin_organization_ids}}, :joins => [:projects])
    else
      Organization.find(:all, :conditions => {:projects => {:id => project_ids}}, :joins => [:projects])
    end
  end
  
  def users_to_export
    organizations_to_export.map{|o| o.users + o.users_in_projects }.flatten.compact
  end
  
  def import_data_file_name
    "#{temp_upload_path}/tbox-import-#{self.id}-#{processed_data_file_name}"
  end
  
  def data
    if @data.nil? and type_name == :import
      begin
        File.open(import_data_file_name) do |f|
          @data = if service == 'basecamp'
            Hash.from_xml f.read
          else
            ActiveSupport::JSON.decode f.read
          end
        end
      rescue
        nil
      end
    else
      @data
    end
  end
end
