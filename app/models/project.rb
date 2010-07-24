# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Project < ActiveRecord::Base
  acts_as_paranoid

  concerned_with :validation,
                 :initializers,
                 :roles,
                 :associations,
                 :callbacks,
                 :archival,
                 :permalink,
                 :invitations

  attr_accessible :name, :permalink, :archived, :group_id, :tracks_time

  def log_activity(target, action, creator_id=nil)
    creator_id ||= target.user_id
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
    end
  end
  
  def transfer_to(person)
    self.user = person.user
    saved = self.save
    person.update_attribute(:role, Person::ROLES[:admin]) if saved # owners need to be admin!
    saved
  end

  def has_member?(user)
    Person.exists?(:project_id => self.id, :user_id => user.id)
  end

  def task_lists_assigned_to(user)
    task_lists.unarchived.inject([]) do |t, task_list|
      person = people.find_by_user_id(user.id)
      t << task_list if task_list.tasks.count(:conditions => {:assigned_id => person.id, :status => Task::STATUSES[:open]}) > 0
      t
    end
  end

  def notify_new_comment(comment)
    users.each do |user|
      if user.notify_of_project_comment?(comment)
        Emailer.send_with_language(:notify_comment, user.language, user, self, comment) # deliver_notify_comment
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
                        :order => 'id DESC',
                        :limit => options[:limit] || APP_CONFIG['activities_per_page'])
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
        next unless task.due_on
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
            port_in_url = (port == 80) ? '' : ":#{port}"
            url         "http://#{host}#{port_in_url}/projects/#{task.project.permalink}/task_lists/#{task.task_list.id}/tasks/#{task.id}"
          end
          klass         task.project.name
          dtstamp       DateTime.civil(created_date.year,created_date.month,created_date.day,created_date.hour,created_date.min,created_date.sec,created_date.offset)
          uid           "tb-#{task.project.id}-#{task.id}"
        end
      end
      ical.to_ical
    end

end
