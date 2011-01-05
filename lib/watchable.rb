module Watchable

  extend ActiveSupport::Memoizable
  
  def self.included(model)
    model.attr_accessible :watchers_ids
    model.serialize :watchers_ids
    model.before_create :add_owner_as_watcher, :if => :user_id?
  end
  
  def watchers_ids=(ids)
    self[:watchers_ids] = ids.map(&:to_i)
  end
  
  def watchers_ids
    self[:watchers_ids] ||= []
  end
  
  def add_watcher(user, persist = !new_record?)
    unless has_watcher?(user)
      watchers_ids << user.id
      flush_cache :watchers # memoize
      save(:validate => false) if persist
    end
  end
  
  def add_watchers(users, persist = !new_record?)
    Array(users).each do |user|
      add_watcher(user, false)
    end
    save(:validate => false) if persist
  end
  
  def has_watcher?(user)
    watchers_ids.include? user.id
  end

  def remove_watcher(user, persist = !new_record?)
    if watchers_ids.delete user.id
      flush_cache :watchers # memoize
      save(:validate => false) if persist
    end
  end
  
  def watchers
    project.users.confirmed.find_all_by_id(watchers_ids)
  end
  memoize :watchers
  
  protected
  
  def add_owner_as_watcher # before_create
    unless watchers_ids.include? user_id
      watchers_ids << user_id
    end
    true
  end

end
