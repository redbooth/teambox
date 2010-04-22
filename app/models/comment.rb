class Comment < ActiveRecord::Base
  
  acts_as_paranoid
  
  concerned_with :associations,
                 :callbacks,
                 :tasks,
                 :finders,
                 :uploads
    
  attr_accessible :body, :user_id, :target_attributes

  formats_attributes :body

  named_scope :with_hours, :conditions => 'hours > 0'

  attr_accessible :status, :previous_status, :assigned, :previous_assigned, :hours
  validate :check_body

  attr_accessor :mentioned # used by format_usernames to set who's being mentioned
  attr_accessor :activity
  
  def check_body
    if body and body.strip.empty?
      if !target.is_a? Task
        @errors.add :body, :no_body_generic
      end
    end
  end
  
  def user
    User.find_with_deleted(user_id)
  end
  
  def can_edit?(current_user)
    # Only the owner can edit their comment
    if self.user_id != current_user.id
      return false
    end
    
    # We can only edit / delete up to 15 minutes after creation
    if Time.now < (self.created_at + 15.minutes)
      true
    else
      false
    end
  end
  
  def can_destroy?(current_user)
    if self.user_id != current_user.id
      return false unless self.project.admin?(current_user)
    end
    
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
end