class TeamboxData < ActiveRecord::Base
  include Immortal

  belongs_to :user
  concerned_with :serialization, :attributes, :teambox, :basecamp
  
  attr_accessible :project_ids, :type_name, :import_data, :user_map, :target_organization, :service
  
  before_validation :set_service, :on => :create
  before_create :check_state
  after_create  :post_check_state
  after_update  :post_check_state
  before_update :check_state
  before_destroy :clear_import_data
  
  has_attached_file :processed_data,
    :url  => "/exports/:id/:basename.:extension",
    :path => Teambox.config.amazon_s3 ?
      "exports/:id/:filename" :
      ":rails_root/exports/:id/:filename"
  
  validate :check_map
  
  def check_map
    @errors.add "service", "Unknown service #{service}" if !['teambox', 'basecamp'].include?(service)
    if type_name == :import and status_name == :mapping
      # user needs to be an admin of the target organization
      if !user.admin_organizations.map(&:permalink).include?(target_organization)
        return @errors.add("target_organization", "Should be an admin")
      end
      
      # All users need to be known to the owner
      users = user.users_for_user_map.map(&:login)
      
      user_map.each do |login,dest_login|
        if !users.include?(dest_login)
          @errors.add "user_map_#{login}", "#{dest_login} Not known to user"
        end
      end
    end
  end
  
  def clear_import_data
    if type_name == :import
      fname = import_data_file_name
      FileUtils.rm(fname) if processed_data_file_name and File.exists?(fname)
      self.processed_data_file_name = nil
    end
  end
  
  def set_service
    self.service ||= 'teambox'
  end
  
  def temp_upload_path
    "/tmp"
  end
  
  def store_import_data
    begin
      # store the import in a temporary file, since we don't need it for long
      bytes = @import_data.read
      File.open(import_data_file_name, 'w') do |f|
        f.write bytes
      end
      @import_data = nil
    rescue Exception => e
      @process_error = e.to_s
      self.status_name = :uploading
    end
  end
  
  def need_data?
    if type_name == :import
      status < IMPORT_STATUSES[:pre_processing]
    else
      status < EXPORT_STATUSES[:pre_processing]
    end
  end
  
  def check_state
    @check_state = true
    if type_name == :import
      case status_name
      when :uploading
        if self.processed_data_file_name and File.exists?("#{temp_upload_path}/#{processed_data_file_name}")
          self.status_name = :mapping
        elsif @import_data
          self.processed_data_file_name = "#{user.login}.json"
          @do_store_import_data = true
          self.status_name = :mapping
        else
          self.processed_data_file_name = nil
        end
      when :mapping
        self.status_name = :processing
        if Teambox.config.delay_data_processing
          self.status_name = :pre_processing
          TeamboxData.send_later(:delayed_import, self.id)
        else
          self.status_name = :processing
          do_import
        end
      end
    else
      case status_name
      when :selecting
        if Teambox.config.delay_data_processing
          self.status_name = :pre_processing
          @dispatch_export = true
        else
          self.status_name = :processing
          do_export
        end
      end
    end
  end
  
  def post_check_state
    if type_name == :export
      Emailer.send_with_language(:notify_export, user.locale, self.id) if @dispatch_notification
      TeamboxData.send_later(:delayed_export, self.id) if @dispatch_export
    elsif type_name == :import
      store_import_data if @do_store_import_data
      Emailer.send_with_language(:notify_import, user.locale, self.id) if @dispatch_notification
    end
  end
  
  def do_import
    self.processed_at = Time.now
    next_status = :imported
    
    begin
      org_map = {}
      organizations.each do |org|
        org_map[org['permalink']] = target_organization
      end
      
      throw Exception.new("Import is invalid") if !valid?
      
      if service == 'basecamp'
        unserialize_basecamp({'User' => user_map, 'Organization' => org_map})
      else
        unserialize({'User' => user_map, 'Organization' => org_map})
      end
    rescue Exception => e
      # Something went wrong?!
      Rails.logger.warn "#{user} imported an invalid dump (#{self.id}) #{e.inspect}"
      self.processed_at = nil
      next_status = :uploading
    end
    
    self.status_name = next_status
    clear_import_data
    @dispatch_notification = true
    
    save unless new_record? or @check_state
  end
  
  def do_export
    self.processed_at = Time.now
    @data = serialize(organizations_to_export, projects, users_to_export)
    upload_data = Tempfile.new("#{user.login}-export")
    upload_data.write(@data.to_json)
    upload_data.seek(0)
    upload = ActionDispatch::Http::UploadedFile.new(:type => 'application/json',
                                                    :filename => "#{user.login}-export.json",
                                                    :tempfile => upload_data)
    self.processed_data = upload
    self.status_name = :exported
    @dispatch_notification = true
    
    save unless new_record? or @check_state
  end
  
  def self.delayed_export(data_id)
    TeamboxData.find_by_id(data_id).try(:do_export)
  end
  
  def self.delayed_import(data_id)
    TeamboxData.find_by_id(data_id).try(:do_import)
  end
  
  def exported?
    type_name == :export && status > EXPORT_STATUSES[:processing]
  end
  
  def imported?
    type_name == :import && status > IMPORT_STATUSES[:processing]
  end
  
  def processing?
    type_name == :import ? [IMPORT_STATUSES[:pre_processing], IMPORT_STATUSES[:processing]].include?(status) :
                           [EXPORT_STATUSES[:pre_processing], EXPORT_STATUSES[:processing]].include?(status)
  end
  
  def error?
    (imported? or exported?) and processed_at.nil?
  end
  
  def users_to_export
    organizations_to_export.map{|o| o.users + o.users_in_projects }.flatten.compact
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :data_type => type_name,
      :service => service,
      :status => status_name,
      :user_id => user_id,
      :processed_at => processed_at,
      :created_at => created_at.to_s(:api_time)
    }
    
    base[:processed_at] = processed_at.to_s(:api_time) if processed_at
    base[:target_organization] = target_organization if target_organization
    base[:project_ids] = project_ids if project_ids
    base[:type] = self.class.to_s if options[:emit_type]
    
    base
  end
end