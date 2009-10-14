require 'digest/sha1'

class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :invited_user, :class_name => 'User'
  
  attr_accessor :user_or_email
  attr_accessible :user_or_email
  
  validates_each :user_or_email do |record, attr, value|
    if value =~ /[a-z0-9_\-\+\.]+@[a-z0-9_\-\.]+/i
      record.email = value
      if Invitation.exists?(:project_id => record.project.id, :email => value)
        record.errors.add attr, 'already has a pending invitation.'
      end
    else
      unless User.exists?(:login => value)
        record.errors.add attr, 'is not a valid username or email.'
      else
        record.invited_user_id = User.find_by_login(value).id
        if Invitation.exists?(:project_id => record.project_id, :invited_user_id => record.invited_user_id)
          record.errors.add attr, 'already has a pending invitation.'
        end
        if Person.exists?(:project_id => record.project_id, :user_id => record.invited_user_id)
          record.errors.add attr, 'is already a member of the project.'
        end
      end
    end
    
  end
  
  def before_save
    if self.token.nil?
      self.token = Digest::SHA1.hexdigest(rand(999999999).to_s) + Time.new.to_i.to_s
    end
  end
end