class EmailAddress < ActiveRecord::Base
  belongs_to :user

  TYPES = ['Work','Home','Other']
  
  def get_type
    TYPES[account_type]
  end
  
end