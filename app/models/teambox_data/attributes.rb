class TeamboxData
  attr_accessor :data
  attr_accessor :import_data
  
  serialize :project_ids
  serialize :processed_objects
  serialize :user_map

  TYPE_LOOKUP = {:import => 0, :export => 1}
  TYPE_CODES = TYPE_LOOKUP.invert

  IMPORT_STATUS_NAMES = [:uploading, :mapping, :pre_processing, :processing, :imported]
  IMPORT_STATUSES = IMPORT_STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }

  EXPORT_STATUS_NAMES = [:selecting, :pre_processing, :processing, :exported]
  EXPORT_STATUSES = EXPORT_STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }

  def user_map
    if self[:user_map].nil?
      known_map = {}
      user.organizations.map{|o| o.users + o.users_in_projects }.flatten.compact.each do |user|
        known_map[user.login] = user
      end

      map = {}
      users.each do |user|
        map[user['username']] = known_map[user['username']].try(:login)
      end
      self[:user_map] = map
    end
    self[:user_map]
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
      Project.where(:id => project_ids, :organization_id => user.admin_organization_ids).all
    else
      Project.where(:id => project_ids).all
    end
  end
  
  def organizations_to_export
    if user
      Organization.where(:projects => {:id => project_ids, :organization_id => user.admin_organization_ids}).joins([:projects]).all
    else
      Organization.where(:projects => {:id => project_ids}).joins([:projects]).all
    end
  end

  def data
    if @data.nil? and type_name == :import
      begin
        data_path = processed_data.path
        if Teambox.config.amazon_s3
          fetch_s3_upload
          data_path = "#{Rails.root}/tmp/#{processed_data.path}"
        end
        File.open(data_path) do |f|
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
