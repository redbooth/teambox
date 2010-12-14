class Conversation < RoleRecord

  # needed for `truncate`
  include ActionView::Helpers::TextHelper
  
  include Watchable

  concerned_with :tasks
  
  attr_accessor :is_importing, :updating_user
  
  has_one  :first_comment, :class_name => 'Comment', :as => :target, :order => 'created_at ASC'
  has_many :recent_comments, :class_name => 'Comment', :as => :target, :order => 'created_at DESC', :limit => 2
  
  has_many :uploads
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
  
  accepts_nested_attributes_for :comments, :allow_destroy => false,
    :reject_if => lambda { |comment| comment['body'].blank? }

  attr_accessible :name, :simple, :body, :comments_attributes

  validates_presence_of :name, :message => :no_title, :unless => :simple?
  
  validate :check_comments_presence, :on => :create, :unless => :is_importing

  scope :only_simple, :conditions => { :simple => true }
  scope :not_simple, :conditions => { :simple => false }
  scope :recent, lambda { |num| { :limit => num, :order => 'updated_at desc' } }

  before_save :set_comments_author, :if => :updating_user

  def before_update
    self.simple = false if simple? and name_changed? and !name.nil?
    true
  end

  def self.from_github(payload)
    text = description_for_github_push(payload)
    
    self.create!(:body => "<div class='hook_github'>#{text}</div>", :simple => true) do |conversation|
      conversation.user = conversation.project.user if conversation.project
      yield conversation if block_given?
    end
  end
  
  def self.description_for_github_push(payload)
    text = "<h3>New code on <a href='%s'>%s</a> %s</h3>\n\n" % [
      payload['repository']['url'], payload['repository']['name'], payload['ref']
    ]
    
    commits = payload["commits"]
    
    commits[0, 10].each do |commit|
      author = commit['author']['name']
      message = commit['message'].strip.split("\n").first
      text << "#{author} - <a href='#{commit['url']}'>#{message}</a><br>\n"
    end
    
    text << "And #{commits.size - 10} more commits" if commits.size > 10
    return text
  end

  def after_create
    project.log_activity(self,'create')
  end

  def after_destroy
    Activity.destroy_all :target_id => self.id, :target_type => self.class.to_s
  end

  def owner?(u)
    user == u
  end
  
  def name=(value)
    value = nil if value.blank?
    self[:name] = value
  end
  
  def body=(value)
    self.comments_attributes = [{ :body => value }] unless value.nil?
  end

  def to_s
    name || ""
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.conversation :id => id do
      xml.tag! 'project-id',      project_id
      xml.tag! 'user-id',         user_id
      xml.tag! 'name',            name
      xml.tag! 'created-at',      created_at.to_s(:db)
      xml.tag! 'updated-at',      updated_at.to_s(:db)
      xml.tag! 'watchers',        watchers_ids.join(',')
      if Array(options[:include]).include? :comments
        comments.to_xml(options.merge({ :skip_instruct => true }))
      end
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :project_id => project_id,
      :user_id => user_id,
      :name => name,
      :simple => simple,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :watchers => Array.wrap(watchers_ids),
      :comments_count => comments_count,
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :thread_comments
      base[:first_comment] = first_comment.to_api_hash(options)  if first_comment
      base[:recent_comments] = recent_comments.map{|c|c.to_api_hash(options)}
    elsif !Array(options[:include]).include?(:comments)
      base[:first_comment_id] = first_comment.try(:id)
      base[:recent_comment_ids] = recent_comments.map{|c|c.id}
    end
    
    if Array(options[:include]).include? :comments
      base[:comments] = comments.map{|c| c.to_api_hash(options)}
    end
    
    base
  end

  define_index do
    where "`conversations`.`deleted_at` IS NULL"

    indexes name, :sortable => true

    indexes comments.body, :as => :body
    indexes comments.user.first_name, :as => :user_first_name
    indexes comments.user.last_name, :as => :user_last_name
    indexes comments.uploads(:asset_file_name), :as => :upload_name
    
    has project_id, created_at, updated_at
  end

  protected
  
  def check_comments_presence
    unless comments.any?
      errors.add :comments, :must_have_one
    end
  end

  def set_comments_author # before_save
    comments.select(&:new_record?).each do |comment|
      comment.user = updating_user
    end
    true
  end
end
