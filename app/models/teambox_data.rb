require 'open-uri'
class TeamboxData < ActiveRecord::Base
  include Immortal

  belongs_to :user
  belongs_to :organization
  concerned_with :serialization, :attributes, :teambox, :basecamp, :validations

  attr_accessible :project_ids, :type_name, :processed_data, :user_map, :target_organization, :service, :organization_id

  has_attached_file :processed_data,
    :url  => "/:data_type/:id/:basename.:extension",
    :path => Teambox.config.amazon_s3 ?
      ":data_type/:id/:filename" :
      ":rails_root/:data_type/:id/:filename"

  before_validation :set_service, :on => :create
  after_save  :post_check_state
  before_save :check_state
  before_destroy :clear_import_data

  def clear_import_data
    if type_name == :import
      self.processed_data.clear
    end
  end

  def fetch_s3_upload
    target_file = "#{Rails.root}/tmp/#{processed_data.path}"
    target_dir = File.dirname target_file

    FileUtils.mkdir_p target_dir unless File.exists? target_dir

    open(URI.escape processed_data.url) do |data|
      File.open target_file, 'w' do |file|
        file.write(data.read)
      end
    end
  end

  def set_service
    self.service ||= 'teambox'
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
      case status_name.to_sym
      when :uploading
        if self.processed_data_file_name and processed_data.exists?
          self.status_name = :mapping
        elsif processed_data
          self.status_name = :mapping
        end
      when :mapping
        self.status_name = :processing
        if Teambox.config.delay_data_processing
          self.status_name = :pre_processing
          @dispatch = true
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
          @dispatch = true
        else
          self.status_name = :processing
          do_export
        end
      end
    end
  end
  
  def post_check_state
    TeamboxData.send_later(:"delayed_#{type_name}", self.id) if @dispatch
    Emailer.send_with_language("notify_#{type_name}", user.locale, self.id) if @dispatch_notification
    store_import_data if @do_store_import_data
  end

  def do_import
    self.processed_at = Time.now
    next_status = :imported

    begin
      org_map = {}
      organizations.each do |org|
        org_map[org['permalink']] = organization.permalink
      end

      throw Exception.new("Import is invalid #{errors.full_messages}") if !valid?

      unserialize({'User' => user_map, 'Organization' => org_map})

    rescue Exception => e
      # Something went wrong?!
      logger.warn "#{user} imported an invalid dump (#{self.id}) #{e.inspect} #{self.errors.inspect}"
      self.processed_at = nil
      next_status = :uploading
    end

    self.status_name = next_status
    @dispatch_notification = true

    save unless new_record? or @check_state
  end

  def do_export
    self.processed_at = Time.now
    @data = serialize(organizations_to_export, projects)
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
    [:pre_processing, :processing].include?(status_name)
  end

  def error?
    (imported? or exported?) and processed_at.nil?
  end

  def downloadable?(user)
    type_name == :export && user.id == user_id
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
    base[:organization_id] = organization_id if organization_id
    base[:project_ids] = project_ids if project_ids
    base[:type] = self.class.to_s if options[:emit_type]
    
    base
  end

  Paperclip.interpolates :data_type do |attachment,style|
    attachment.instance.type_name.to_s.pluralize
  end

  def self.logger
    @logger ||= Logger.new(Rails.root.join("log/teambox_datas.log"))
    @logger.formatter = Logger::Formatter.new
    @logger
  end

end
