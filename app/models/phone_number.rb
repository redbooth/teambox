class PhoneNumber < ActiveRecord::Base
  belongs_to :card

  TYPES = ['Work','Mobile','Fax','Home','Skype','Other']
  
  def get_type
    TYPES[account_type]
  end
  
end  