module Watchable
  def touch_watchers
    @watch_touch = (@watch_touch || 0) + 1
  end
  
  def add_watcher(user)
    @cached_watchers = nil
    self.watchers_ids ||= []
    self.watchers_ids << user.id
    self.watchers_ids.uniq!
    touch_watchers
    self.save(false) unless new_record?
  end
  
  def add_watchers(users)
    Array(users).each do |user|
      self.add_watcher user
    end
  end
  
  def watching?(user)
    self.watchers_ids ||= []
    !!self.watchers_ids.index(user.id)
  end

  def remove_watcher(user)
    @cached_watchers = nil
    self.watchers_ids ||= []
    self.watchers_ids.delete user.id
    touch_watchers
    self.save(false)
  end
  
  def sync_watchers
    old_watchers = self.watchers_ids
    self.watchers_ids = self.watchers.collect(&:id).uniq
    self.save(false) unless old_watchers == self.watchers_ids
  end
  
  def watchers
    # Handle caching
    reloaded = @last_watchers != self.watchers_ids or @watch_touch != @last_watch_touch
    self.watchers_ids ||= []
    @last_watchers = self.watchers_ids
    @last_watch_touch = @watch_touch
    
    if reloaded or @cached_watchers.nil?
      # Find all users with a join on People to the objects project
      fields = 'users.id AS id, email, first_name, last_name, language, notify_conversations, notify_task_lists, notify_tasks, time_zone'
      @cached_watchers = User.find(:all,
                                   :conditions => {
                                     :id => self.watchers_ids, 
                                     :people => {:project_id => self.project_id, :deleted_at => nil}
                                   }, 
                                   :joins => [:people],
                                   :select => fields)
    end
    
    @cached_watchers
  end

  def watchable?
    true
  end
end