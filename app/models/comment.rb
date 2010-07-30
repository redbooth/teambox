class Comment < ActiveRecord::Base
  
  acts_as_paranoid
  
  concerned_with :associations,
                 :callbacks,
                 :tasks,
                 :finders

  attr_accessible :body, :user_id, :target_attributes, :status, :previous_status,
                  :assigned, :previous_assigned, :human_hours

  formats_attributes :body

  named_scope :with_hours, :conditions => 'hours > 0'

  validate_on_create :check_duplicates
  validate :check_body

  attr_accessor :mentioned # used by format_usernames to set who's being mentioned
  attr_accessor :activity

  def hours?
    hours and hours > 0
  end

  def human_hours
    self.hours
  end

  # Instead of using the float 'hours' field in a form, we use 'human_hours'
  # and we can take:
  # 7 (hours)
  # 7.5 (hours with decimals)
  # 7h (hours)
  # 30m (minutes => fractions of hours)
  # 2h 30m (hours and minutes => hours with decimals)
  # 2:30 (hours and minutes => hours with decimals)
  def human_hours=(duration)
    self.hours = if duration =~ /(\d+)h[ ]*(\d+)m/i
      # 2h 15m
      $1.to_f + $2.to_f / 60
    elsif duration =~ /(\d+):(\d+)/
      # 2:15
      $1.to_f + $2.to_f / 60.0
    elsif duration =~ /(\d+)m/i
      # 20m
      $1.to_f / 60.0
    elsif duration =~ /(\d+)h/i
      # 3h
      $1.to_f
    else
      # old-style numeric format
      duration.to_f
    end
  end

  def check_body
    if body and body.strip.empty?
      if !target.is_a? Task
        @errors.add :body, :no_body_generic
      end
    end
  end

  define_index do
    indexes body, :sortable => true
#    indexes user(:name)
    indexes uploads(:asset_file_name), :as => :upload_name
    indexes target.name, :as => :target

    has user_id, project_id, created_at
  end
  
  # We will not allow two comments in a row with the body, target and assigned_to
  def check_duplicates
    last = Comment.find(:first, :conditions =>
                    ["user_id = ? AND target_id = ? AND target_type LIKE ?",
                      user_id, target_id, target_type], :order => "id DESC")

    if last && last.body == body && last.assigned_id == assigned_id \
      && last.status == status && last.hours == hours
      @errors.add :body, "Duplicate comment"
    end
  end
  
  def user
    User.find_with_deleted(user_id)
  end
  
  def can_modify?(current_user, limit=true)
    can_edit?(current_user, limit) or can_destroy?(current_user, limit)
  end
  
  def can_edit?(current_user, limit=true)
    # Only the owner can edit their comment
    if self.user_id != current_user.id
      return false
    end
    
    return true unless limit
    
    # We can only edit / delete up to 15 minutes after creation
    if Time.now < (self.created_at + 15.minutes)
      true
    else
      false
    end
  end
  
  def can_destroy?(current_user, limit=true)
    # admins can remove at any time, users
    # need to own the comment
    return true if self.project.admin?(current_user)
    return false if self.user_id != current_user.id
    
    return true unless limit
    
    # 15 minutes restriction
    if Time.now < (self.created_at + 15.minutes)
      true
    else
      false
    end
  end
  
  def day
    if self.created_at.mday.to_s.length == 1
      current_day = "0#{self.created_at.mday.to_s}"
    else
      current_day =  self.created_at.mday.to_s
    end
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
      unless Array(options[:include]).include? :comments
        xml.tag! 'project-id', project_id
        xml.tag! 'target-id', target.id
        xml.tag! 'target-type', target.class
      end
      if target.is_a? Task
        xml.tag! 'assigned-id', assigned_id
        xml.tag! 'previous-assigned-id', previous_assigned_id
        xml.tag! 'previous-status', previous_status
        xml.tag! 'status', status
      end
      if uploads.any?
        xml.files :count => uploads.size do
          for upload in uploads
            upload.to_xml(options.merge({ :skip_instruct => true }))
          end
        end
      end
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :body => body,
      :body_html => body_html,
      :created_at => created_at.to_s(:db),
      :updated_at => updated_at.to_s(:db),
      :user => {
        :username => user.login,
        :first_name => user.first_name,
        :last_name => user.last_name,
        :avatar_url => user.avatar_or_gravatar_url(:thumb)
      },
      :project_id => project_id,
      :target_id => target_id,
      :target_type => target_type
    }
    
    if target.is_a? Task
      base[:assigned_id] = assigned_id
      base[:previous_assigned_id] = previous_assigned_id
      base[:previous_status] = previous_status
      base[:status] = status
    end
    
    if uploads.any?
      base[:uploads] = uploads.map {|u| u.to_api_hash(options)}
    end
    
    base
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end
end