require 'digest/sha1'

class Invitation < RoleRecord
  belongs_to :user, :validate => true
  belongs_to :project, :validate => true
  belongs_to :invited_user, :class_name => 'User'
  
  attr_accessor :user_or_email
  attr_accessible :user_or_email, :user
  
  validates_presence_of :user

  validates_each :user_or_email do |record, attr, value|
    invited_user ||= User.find_by_username_or_email value
    
    if invited_user
      # existing Teambox user
      record.invited_user_id = invited_user.id
      if Person.exists?(:project_id => record.project_id, :user_id => record.invited_user_id)
        record.errors.add attr, 'is already a member of the project'
      elsif Invitation.exists?(:project_id => record.project.id, :invited_user_id => invited_user.id)
        record.errors.add attr, 'already has a pending invitation'
      else
        record.invited_user = invited_user
        record.email = invited_user.email
      end
    else
      # unexisting Teambox user
      if value =~ /[a-z0-9_\-\+\.]+@[a-z0-9_\-\.]+/i
        if Invitation.exists?(:project_id => record.project.id, :email => value)
          record.errors.add attr, 'already has a pending invitation'
        else
          record.invited_user = nil
          record.email = value
        end
      else
        record.errors.add attr, 'is not a valid username or email'
      end
    end
    # SHOULD ONLY BE ABLE TO INVITE TO PROJECTS WHERE THE INVITING USER IS ALLOWED
    # TODO: IMPLEMENT User#can_invite?(project) AND USE IT HERE
  end
  
  def send_email
    if invited_user
      Emailer.deliver_project_invitation self
    else
      Emailer.deliver_signup_invitation self
    end
  end

  def before_save
    self.token ||= Digest::SHA1.hexdigest(rand(999999999).to_s) + Time.new.to_i.to_s
  end
  
  def after_save
    send_email
  end
end