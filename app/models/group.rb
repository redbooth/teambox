class Group < ActiveRecord::Base
  
  concerned_with :logo,
                 :validation,
                 :associations,
                 :callbacks
  
  acts_as_paranoid
  
  def owner?(user)
    self.user_id == user.id
  end
  
  def admin?(user)
    self.has_member?(user)
  end
  
  def has_member?(user)
    self.user_ids.include? user.id
  end
  
  def add_user(user)
    self.users << user
    self.users.uniq!
    save(false)
  end
  
  def remove_user(user)
    if !self.owner?(user)
      self.users.delete(user)
      save(false)
    end
  end
  
  def to_param
    permalink
  end
  
end
