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

  attr_accessible :name, :permalink, :archived, :tracks_time, :public, :organization_attributes, :organization_id
  has_many :google_docs
  
  attr_accessor :is_importing
  attr_accessor :import_activities
  
  def self.find_by_id_or_permalink(param)
    if param =~ /^\d+$/
      find(param)
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
      people.build.tap do |person|
        person.user = user
        person.role = params[:role] if params[:role]
        person.source_user_id = params[:source_user].try(:id)
        person.save
      end
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
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :organization_id => organization_id,
      :name => name,
      :permalink => permalink,
      :archived => archived,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :archived => archived,
      :owner_user_id => user_id
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :people
      base[:people] = people.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :task_lists
      base[:task_lists] = task_lists.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :invitations
      base[:invitations] = invitations.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :pages
      base[:pages] = pages.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :uploads
      base[:uploads] = uploads.map {|p| p.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :conversations
      base[:conversations] = conversations.map {|p| p.to_api_hash(options)}
    end
    
    base
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
            summary "#{task.project}: #{task}"
          else
            summary task.name
          end
          if host
            port_in_url = (port == 80) ? '' : ":#{port}"
            url         "http://#{host}#{port_in_url}/projects/#{task.project.permalink}/tasks/#{task.id}"
          end
          klass         task.project.name
          dtstamp       DateTime.civil(created_date.year,created_date.month,created_date.day,created_date.hour,created_date.min,created_date.sec,created_date.offset)
          uid           "tb-#{task.project.id}-#{task.id}"
        end
      end
      ical.to_ical
    end

end
