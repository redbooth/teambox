class Comment < ActiveRecord::Base

  has_many :uploads
  belongs_to :user
  belongs_to :project
  belongs_to :target, :polymorphic => true, :counter_cache => true
  accepts_nested_attributes_for :target
  
  acts_as_paranoid
    
  attr_accessible :body, :hours, :status, :user_id, :target_attributes
  formats_attributes :body

  named_scope :ascending, :order => 'created_at ASC'
  named_scope :descending, :order => 'created_at DESC'
  named_scope :with_uploads, :conditions => 'hours > 0'
  named_scope :with_hours, :conditions => 'hours > 0'

  attr_accessor :activity

  def after_create
    self.target.reload

    if self.target_type == 'User'
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

  def status_name
    Task::STATUSES[status.to_i].underscore
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
        upload.save(false)
      end
    end
    
    params[:uploads_deleted].if_defined.each do |upload_id|
      upload = Upload.find(upload_id)
      upload.destroy if upload
    end
  end
  

end