# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Project < ActiveRecord::Base

  include GrabName
  
  acts_as_paranoid

  concerned_with :validation, 
                 :initializers, 
                 :roles, 
                 :associations,
                 :callbacks
                 #:logo


  has_permalink :name

  attr_accessible :name, :permalink, :archived

  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}

  def self.grab_name_by_permalink(permalink)
    p = self.find_by_permalink(permalink,:select => 'name')
    p.try(:name) || ''
  end
  

  def log_activity(target, action, creator_id=nil)
    creator_id = target.user_id unless creator_id
    Activity.log(self, target, action, creator_id)
  end
  
  def add_user(user, source_user=nil)
    unless Person.exists? :user_id => user.id, :project_id => id
      people.create(:user_id => user.id, :source_user_id => source_user.try(:id))
    end
  end
  
  def remove_user(user)
    if person = Person.find_by_user_id_and_project_id(user.id, id)
      person.destroy

      user.recent_projects.delete id
      user.save!      
    end
  end
  
  def to_param
    permalink
  end

  def task_lists_assigned_to(user)
    task_lists.unarchived.inject([]) do |t, task_list|
      person = people.find_by_user_id(user.id)
      t << task_list if task_list.tasks.count(:conditions => {:assigned_id => person.id, :status => Task::STATUSES[:open]}) > 0 
      t
    end
  end

  def after_comment(comment)
    notify_new_comment(comment)
  end

  def notify_new_comment(comment)
    self.users.each do |user|
      if user != comment.user and user.notify_mentions and " #{comment.body} ".match(/\s@#{user.login}\W/i)
        Emailer.deliver_notify_comment(user, self, comment)
      end
    end
  end

  # Optimized way of getting activities for one or more project.
  # Can limit the number of records and page.
  def self.get_activities_for(projects, *args)
    options = args.extract_options!

    if options[:before]
      conditions = ["project_id IN (?) AND id < ?", Array(projects).collect{ |p| p.id }, options[:before] ]
    elsif options[:after]
      conditions = ["project_id IN (?) AND id > ?", Array(projects).collect{ |p| p.id }, options[:after] ]
    else
      conditions = ["project_id IN (?)", Array(projects).collect{ |p| p.id } ]
    end

    Activity.find(:all, :conditions => conditions,
                        :order => 'created_at DESC',
                        :limit => options[:limit] || APP_CONFIG['activities_per_page'])
  end
  
  def get_recent(model_class, limit = 5)
    model_class.find(:all, :conditions => ["project_id = ?", id],
                           :order => 'created_at DESC',
                           :limit => limit)
  end

  def to_s
    name
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.project :id => id do
      xml.tag! 'name', name
      xml.tag! 'permalink', permalink
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'archived', archived
      xml.tag! 'owner-user-id', user_id
      xml.people :count => people.size do
        for person in people
          person.to_xml(options.merge({ :skip_instruct => true, :root => :person }))
        end
      end
    end
  end
end