class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true, :counter_cache => true
  belongs_to :project

  has_many :uploads
    
  attr_accessible :body, :hours, :status
  formats_attributes :body

  named_scope :ascending, :order => 'created_at ASC'
  named_scope :descending, :order => 'created_at DESC'
  named_scope :with_uploads, :conditions => 'hours > 0'
  named_scope :with_hours, :conditions => 'hours > 0'

  attr_accessor :activity

  def after_create
    target.last_comment_id = id
    target.save(false)
    
    project.last_comment_id = id
    project.save(false)
    
    self.target.reload
    if self.target_type == 'Conversation'
      target.notify_new_comment(self)
    end
    
    self.activity = project.log_activity(self,'create')
  end
  
  def after_destroy
    Activity.destroy_all :target_type => self.class.to_s, :target_id => self.id

    if target
      original_id = target.last_comment_id  
      
      last_comment = Comment.find(:first, :conditions => {
          :target_type => target.class.name,
          :target_id => target.id},
          :order => 'id DESC')

      if last_comment.nil?
        target.last_comment_id = nil
        CommentRead.delete_all :target_type => target.class.name, :target_id => target.id
      else
        target.last_comment_id = last_comment.id
        CommentRead.update_all("last_read_comment_id = #{last_comment.id}",
          :target_type => target.class.name,
          :target_id => target.id,
          :last_read_comment_id => original_id)
      end
      target.save(false)
    end
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
  
end