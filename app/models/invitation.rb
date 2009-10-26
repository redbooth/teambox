require 'digest/sha1'

class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :invited_user, :class_name => 'User'
  
  attr_accessor :user_or_email, :invite_username, :invite_email
  attr_accessible :user_or_email

  validates_associated :user

  validates_each :user_or_email do |record, attr, value|
    invited_user = User.find_by_username_or_email value
    if invited_user # existing Teambox user
      record.invited_user_id = invited_user.id
      if Person.exists?(:project_id => record.project_id, :user_id => record.invited_user_id)
        record.errors.add attr, 'is already a member of the project'
      elsif Invitation.exists?(:project_id => record.project.id, :invited_user_id => invited_user.id)
        record.errors.add attr, 'already has a pending invitation'
      else
        record.user = invited_user
        record.email = invited_user.email
      end
    else # unexisting Teambox user
      if value =~ /[a-z0-9_\-\+\.]+@[a-z0-9_\-\.]+/i
        if Invitation.exists?(:project_id => record.project.id, :email => value)
          record.errors.add attr, 'already has a pending invitation'
        else
          record.email = value
        end
      else
        record.errors.add attr, 'is not a valid username or email'        
      end
    end
  end
  
  def before_save
    if self.token.nil?
      self.token = Digest::SHA1.hexdigest(rand(999999999).to_s) + Time.new.to_i.to_s
    end
  end
end