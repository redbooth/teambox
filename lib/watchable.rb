module Watchable
  def self.included(model)
    model.after_save :update_watchers
    model.attr_accessible :watchers_ids, :watcher_ids
    model.send :attr_writer, :watchers_ids
    model.has_many :watcher_tags, :as => :watchable, :class_name => 'Watcher', :dependent => :destroy
    model.has_many :watchers, :through => :watcher_tags, :source => :user
  end

  def watchers_ids
    warn "[DEPRECIATION] `watchers_ids` is deprecated.  Please use `watcher_ids` instead."
    watcher_ids
  end

  def add_watcher(user)
    unless has_watcher?(user) or !project.has_member?(user)
      watcher = Watcher.new(:user_id => user[:id], :project_id => self.project_id,
                            :watchable_id => self.id, :watchable_type => self.class.to_s)
      true if watcher.save
    end
  end
  
  def add_watchers(users)
    users.each do |user|
      add_watcher(user)
    end
  end
  
  def has_watcher?(user)
    watchers(true).include? user
  end

  def remove_watcher(user)
    if has_watcher?(user)
      watchers = Watcher.where(:watchable_id => self[:id], :watchable_type => self.class, :user_id => user[:id])
      true if watchers.destroy_all
    end
  end

  def people_watching
    Person.where(:user_id => watcher_ids, :project_id => project)
  end

  def people_ids_watching
    people_watching.select(:id).map(&:id)
  end

  protected

  def update_watchers
    add_watcher(user) if user_id_changed?
    if @watchers_ids
      add_watchers(project.users.where(:id => @watchers_ids))
    end
    true
  end

end
