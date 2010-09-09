class Hook < ActiveRecord::Base
    
  belongs_to :user
  belongs_to :project

  attr_accessible :name, :message

  def before_create
    self.key = ActiveSupport::SecureRandom.hex(10)
  end
end