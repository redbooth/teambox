module Watchable
  def self.included(model)
    model.before_save :before_save_collection_association
    model.after_save :update_watchers
    model.after_update :autosave_associated_records_for_watchers
    model.after_create :create_watchers, :autosave_associated_records_for_watchers
    model.attr_accessible :watchers_ids, :watcher_ids
    model.send :attr_writer, :watchers_ids
    model.has_many :watcher_tags, :as => :watchable, :class_name => 'Watcher', :dependent => :destroy
    #Make it obvious that autosave is acting here
    model.has_many :watchers, :through => :watcher_tags, :source => :user, :autosave => true
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
  
  def set_private!(value)
    self.is_private = value
    Activity.where(:target_type => self.class.to_s, :target_id => self.id).each{|a| a.update_attribute(:is_private, value)}
    Activity.where(:comment_target_type => self.class.to_s, :comment_target_id => self.id).each{|a| a.update_attribute(:is_private, value)}
    save!
  end

  protected

  def update_watchers
    add_watcher(user) if user_id_changed?
    if @watchers_ids
      add_watchers(project.users.where(:id => @watchers_ids))
    end
    true
  end

  def create_watchers
    users = project.people.where("watch_new_#{self.class.to_s.downcase}".to_sym => true).map(&:user)
    add_watchers(users)
  end

  # Override to rescue uniqueness errors from db
  # Note: Rather than just removing update_watchers
  # (which also checks for user changes)
  # we rescue StatementInvalid uniqueness errors
  def autosave_associated_records_for_watchers
    reflection = self.class.reflect_on_association(:watchers)
    begin
      save_collection_association(reflection)
    rescue ActiveRecord::StatementInvalid => sie
      raise sie unless duplicate_watchers?
    end
  end

  def duplicate_watchers?
    watcher_ids.any? do |watcher_id|
      Watcher.where(:watchable_type => self.class.name, :watchable_id => self.id, :user_id => watcher_id).count > 0
    end
  end
end
