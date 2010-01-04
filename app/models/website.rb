class Website < ActiveRecord::Base
  belongs_to :user

  TYPES = ['Work','Personal','Other']
  
  def get_type
    TYPES[account_type]
  end
  
  def to_url
      if name.include? "://"
          name
      else
          "http://#{name}"
      end
  end
end