class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  belongs_to :project
  has_many :uploads
    
  attr_accessible :body, :hours
  formats_attributes :body

  named_scope :ascending, :order => 'created_at ASC'
  named_scope :descending, :order => 'created_at DESC'
  named_scope :with_uploads, :conditions => 'hours > 0'
  named_scope :with_hours, :conditions => 'hours > 0'

  attr_accessor :activity

  def after_create
    target.last_comment_id = id
    target.save(false)
    
    self.activity = project.log_activity(self,'create')
  end

  def day
    self.created_at.strftime('%d')
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
  
  def self.get_comments(user,target,show = 'all')
    if user.comments_ascending
      order = 'comments.created_at ASC'
    else
      order = 'comments.created_at DESC'
    end
  
    if show == 'hours'
      target.comments.find(:all,:conditions => [ 'hours IS NOT NULL and hours > 0'], :order => order)
    elsif show == 'uploads'
      target.comments.find(:all,
        :select => 'comments.*',
        :joins => 'INNER JOIN uploads ON (uploads.comment_id = comments.id)',
        :order => order)
    else
      target.comments.find(:all,:order => order)
    end
  end
  
  def self.get_target(target_name,target_id)
    target_name.constantize.find(target_id)
  end
    
end