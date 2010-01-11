class Comment < ActiveRecord::Base

  has_many :uploads
  belongs_to :user
  belongs_to :project
  belongs_to :target, :polymorphic => true, :counter_cache => true
  belongs_to :assigned, :class_name => 'Person'
  belongs_to :previous_assigned, :class_name => 'Person'  
  accepts_nested_attributes_for :target
  
  acts_as_paranoid
    
  attr_accessible :body, :status, :previous_status, :user_id, :target_attributes, :assigned, :previous_assigned
  formats_attributes :body

  named_scope :ascending, :order => 'created_at ASC'
  named_scope :descending, :order => 'created_at DESC'
  named_scope :with_uploads, :conditions => 'hours > 0'
  named_scope :with_hours, :conditions => 'hours > 0'

  attr_accessor :activity

  def before_create
    if self.target.is_a?(Task)
      self.previous_status = target.previous_status
      self.assigned = target.assigned
      self.previous_assigned_id = target.previous_assigned_id
    end  
  end

  def after_create
    self.target.reload

    if self.target.is_a?(User)
      self.activity = target.log_activity(self,'create')
    else
      target.last_comment_id = id
      target.save(false)
    
      project.last_comment_id = id
      project.save(false)  

      self.activity = project.log_activity(self,'create')
    end

    target.after_comment(self) if target.respond_to?(:after_comment)
  end
  
  def after_destroy
    Activity.destroy_all :target_type => self.class.to_s, :target_id => self.id

    if target
      original_id = target.last_comment_id  
      
      last_comment = Comment.find(:first, :conditions => {
          :target_type => target.class.name,
          :target_id => target.id},
          :order => 'id DESC')

      if last_comment
        target.last_comment_id = last_comment.id
      else
        target.last_comment_id = nil
      end
      target.save(false)
    end
  end

  def previously_closed?
    [Task::STATUSES[:rejected],Task::STATUSES[:resolved]].include?(previous_status)
  end
  
  def transition?
    status_transition? || assigned_transition?
  end
    
  def assigned_transition?
    assigned != previous_assigned
  end
  
  def status_transition?
    status != previous_status
  end

  def assigned?
    !assigned.nil?    
  end

  def previous_assigned?
    !previous_assigned.nil?
  end

  def status_open?
    Task::STATUSES[:open] == status
  end

  def previous_status_open?
    Task::STATUSES[:open] == previous_status
  end
  
  def status_name
    key = nil
    Task::STATUSES.each{|k,v| key = k.to_s if status.to_i == v.to_i } 
    key
  end

  def previous_status_name
    key = nil
    Task::STATUSES.each{|k,v| key = k.to_s if previous_status.to_i == v.to_i } 
    key
  end

  def day
    I18n.l(self.created_at, :format => '%d')
  end

  def self.find_by_year(year=nil)
    year ||= Time.new.year
    find(:all, :conditions => ["YEAR(created_at) = ?", year], :order => 'created_at DESC')
  end
  
  def self.find_by_year_count(year=nil)
    year ||= Time.new.year
    count(:all, :conditions => ["YEAR(created_at) = ?", year])
  end

  def self.find_by_month(month_number=nil,year_number=nil)
    month_number ||= Time.new.month
    with_scope(:find => { :conditions => ["MONTH(created_at) = ?", month_number], :order => 'created_at DESC'}) do
      find_by_year(year_number)
    end
  end

  def self.find_by_week(week_number=nil)
    week_number ||= (Time.new.beginning_of_week - 7.days).strftime("%U").to_i + 1

    with_scope(:find => { :conditions => ["WEEK(created_at) = ?", week_number], :order => 'created_at DESC'}) do
      find_by_year
    end
  end
  
  def self.find_today
    with_scope(:find => { :conditions => ["DAY(created_at) = ?", Time.current.day], :order => 'created_at ASC'}) do
      find_by_year
      find_by_month
    end
  end

  def save_uploads(params)      
    params[:uploads].if_defined.each do |upload_id|
      if upload = Upload.find(upload_id)
        upload.comment_id = self.id
        upload.description = truncate(h(upload.comment.body), :length => 80)
        upload.save(false)
      end
    end
    
    params[:uploads_deleted].if_defined.each do |upload_id|
      upload = Upload.find(upload_id)
      upload.destroy if upload
    end
  end
  
  def user
    User.find_with_deleted(user_id)
  end
  
  def to_s
    body[0,80]
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.comment :id => id do
      xml.tag! 'body', body
      xml.tag! 'body-html', body_html
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'user-id', user_id
      xml.tag! 'project-id', project_id
      xml.tag! 'target-id', target.id
      xml.tag! 'target-type', target.class
      if target.is_a? Task
        xml.tag! 'assigned-id', assigned_id
        xml.tag! 'previous-assigned-id', previous_assigned_id
        xml.tag! 'previous-status', previous_status
        xml.tag! 'status', status
      end
      if uploads.any?
        xml.files :count => uploads.size do
          for upload in uploads
            upload.to_xml(options.merge({ :skip_instruct => true, :root => :files }))
          end
        end
      end
    end
  end
end