require 'digest/sha1'

class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  attr_accessible :email
  
  def before_save
    if self.token.nil?
      self.token = Digest::SHA1.hexdigest(rand(999999999).to_s)
    end
  end
end