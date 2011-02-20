# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Project < ActiveRecord::Base
  include Immortal

  concerned_with :validation,
                 :initializers,
                 :roles,
                 :associations,
                 :callbacks,
                 :archival,
                 :permalink,
                 :invitations,
                 :conversions

  attr_accessible :name, :permalink, :archived, :tracks_time, :public, :organization_attributes, :organization_id
  has_many :google_docs
  
  attr_accessor :is_importing
  attr_accessor :import_activities
  
  def self.find_by_id_or_permalink(param)
    if param.to_s =~ /^\d+$/
      find_by_id(param)
    else
      find_by_permalink(param)
    end
  end

  def log_activity(target, action, creator_id=nil)
    creator_id ||= target.user_id
    return log_later(target, action, creator_id) if self.is_importing
    Activity.log(self, target, action, creator_id)
  end
  
  def log_later(target, action, creator_id)
    @import_activities ||= []
    base = {:date => target.try(:created_at) || nil,
            :project => self,
            :action => action,
            :creator_id => creator_id,
            :target_id => target.id,
            :target_class => target.class}
    if target.is_a? Comment
      base[:comment_target_type] = target.target_type
      base[:comment_target_id] = target.target_id
    end
    @import_activities << base
  end
  
  def add_user(user, params={})
    unless has_member?(user)
      person = Person.with_deleted.where(:project_id => self.id, :user_id => user.id).first
      person ||= people.build
      
      person.user = user
      person.role = params[:role] if params[:role]
      person.source_user_id = params[:source_user].try(:id)
      person.deleted = false
      person.save
      person
    end
  end

  def remove_user(user)
    people.find_by_user_id(user.id).try(:destroy)
  end

  def transfer_to(person)
    self.user = person.user
    saved = self.save
    person.update_attribute(:role, Person::ROLES[:admin]) if saved # owners need to be admin!
    saved
  end

  def has_member?(user)
    people.exists?(:user_id => user.id)
  end

  def task_lists_assigned_to(user)
    task_lists.unarchived.inject([]) do |t, task_list|
      person = people.find_by_user_id(user.id)
      t << task_list if task_list.tasks.count(:conditions => {:assigned_id => person.id, :status => Task::STATUSES[:open]}) > 0
      t
    end
  end

  def get_recent(model_class, limit = 5)
    model_class.find(:all, :conditions => ["project_id = ?", id],
                           :order => 'id DESC',
                           :limit => limit)
  end

  def to_s
    name
  end

  def to_param
    permalink
  end

  def to_ical(filter_user = nil)
    Project.calendar_for_tasks(tasks, self, filter_user)
  end

  def self.to_ical(projects, filter_user = nil, host = nil, port = 80)
    tasks = projects.collect{ |p| p.tasks }.flatten
    self.calendar_for_tasks(tasks, projects, filter_user, host, port)
  end
  
  protected

    def self.calendar_for_tasks(tasks, projects, filter_user, host = nil, port = 80)
      calendar_name = case projects
      when Project then projects.name
      else "Teambox - All Projects"
      end

      if filter_user
        tasks = tasks.select { |task| task.assigned.try(:user_id) == filter_user.id }
      end

      ical = Icalendar::Calendar.new
      ical.product_id = "-//Teambox//iCal 2.0//EN"
      ical.custom_property("X-WR-CALNAME;VALUE=TEXT", calendar_name)
      ical.custom_property("METHOD","PUBLISH")
      tasks.each do |task|
        next unless task.due_on && task.active?
        date = task.due_on
        created_date = task.created_at.to_time.to_datetime
        ical.event do
          dtstart       Date.new(date.year,date.month,date.day)
          dtend         Date.new(date.year,date.month,date.day) + 1.day
          dtstart.ical_params  = {"VALUE" => "DATE"}
          dtend.ical_params    = {"VALUE" => "DATE"}
          if projects.is_a?(Array) && projects.size > 1
            summary "#{task} (#{task.project})"
          else
            summary task.name
          end
          if host
            base_url = if port == 80
              "http://#{host}"
            elsif port == 443
              "https://#{host}"
            else
              "http://#{host}:#{port}"
            end
            url         "#{base_url}/#{task.project.permalink}/tasks/#{task.id}"
          end
          klass         "PRIVATE"
          dtstamp       DateTime.civil(created_date.year,created_date.month,created_date.day,created_date.hour,created_date.min,created_date.sec,created_date.offset)
          uid           "tb-#{task.project.id}-#{task.id}"
        end
      end
      ical.to_ical
    end

end
