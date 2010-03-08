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
  
  def to_url
    if name.include? ".com/"
      name
    else
      case get_network_type
        when 'Twitter'      then "http://www.twitter.com/#{name}"
        when 'Facebook'     then "http://www.facebook.com/#{name}"
        when 'Linked In'    then "http://www.linkedin.com/in/#{name}"
        when 'FriendFeed'   then "http://www.friendfeed.com/#{name}"
        when 'MySpace'      then "http://www.myspace.com/#{name}"
        when 'Seesmic'      then "http://www.seesmic.tv/#{name}"
        when 'Delicious'    then "http://www.delicious.com/#{name}"
        when 'Stumble Upon' then "http://#{name}.stumbleupon.com/"
      end
    end
  end
end