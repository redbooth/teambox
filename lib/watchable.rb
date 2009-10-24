module Watchable

  def add_follower(user)
    self.followers_ids ||= []
    self.followers_ids << user.id
    self.save
  end

  def remove_follower(user)
    self.followers_ids ||= []
    self.followers_ids.delete user.id
    self.save
  end
  
  def followers
    return [] unless self.followers_ids
    self.followers_ids.collect do |id|
      User.find id, :select => "id, email, name, language"
    end
  end

end