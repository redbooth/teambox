class Hook < ActiveRecord::Base
    
  belongs_to :user
  belongs_to :project

  attr_accessible :name, :message

  def generate_token
    self.token = ActiveSupport::SecureRandom.hex(10)
  end

  def before_create
    self.generate_token
  end
end