class Conversation < RoleRecord

  # needed for `truncate`
  include ActionView::Helpers::TextHelper
  
  include Watchable
  
  attr_accessor :is_importing
  
  has_many :uploads
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
  
  accepts_nested_attributes_for :comments, :allow_destroy => false,
    :reject_if => lambda { |comment| comment['body'].blank? }

  attr_accessible :name, :simple, :body, :comments_attributes

  validates_presence_of :name, :message => :no_title, :unless => :simple?
  
  validate :check_comments_presence, :on => :create, :unless => :is_importing

  named_scope :only_simple, :conditions => { :simple => true }
  named_scope :not_simple, :conditions => { :simple => false }
  named_scope :recent, lambda { |num| { :limit => num, :order => 'updated_at desc' } }

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
    
    if Array(options[:include]).include? :comments
      base[:comments] = comments.map{|c| c.to_api_hash(options)}
    end
    
    base
  end

  protected
  
  def check_comments_presence
    unless comments.any?
      errors.add :comments, :must_have_one
    end
  end
end