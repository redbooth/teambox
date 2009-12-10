class SocialNetwork < ActiveRecord::Base
  belongs_to :user
  NETWORK_TYPES = ['Twitter','Facebook','Linked In','FriendFeed','MySpace','Seesmic','Delicious','Stumble Upon','Other']
  TYPES = ['Personal','Business','Other']

  def get_network_type
    NETWORK_TYPES[account_network_type]
  end
  
  def get_type
    TYPES[account_type]
  end
end