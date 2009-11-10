class SocialNetwork < ActiveRecord::Base
  belongs_to :user
  NETWORK_TYPES = ['Twitter','Facebook','Linked In','FriendFeed','MySpace','Seesmic','Delicious','Stumble Upon','Other']
  TYPES = ['Personal','Business','Other']
end