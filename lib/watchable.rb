module Watchable

  def add_watcher(user)
    self.watchers_ids ||= []
    self.watchers_ids << user.id
    self.watchers_ids.uniq!
    self.save!
  end
  
  def add_watchers(users)
    users.each do |user|
      self.add_watcher user
    end
  end

  def remove_watcher(user)
    self.watchers_ids ||= []
    self.watchers_ids.delete user.id
    self.save!
  end
  
  def watchers
    self.watchers_ids.if_defined.collect do |id|
      User.find id, :select => "id, email, first_name, last_name, language"
    end
  end

end