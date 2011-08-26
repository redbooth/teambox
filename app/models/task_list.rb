class TaskList < RoleRecord
  include Immortal

  attr_accessor :template
  attr_accessible :name, :start_on, :finish_on

  concerned_with :validation,
                 :initializers,
                 :scopes,
                 :associations,
                 :callbacks,
                 :conversions

  before_save :ensure_date_order
  
  def self.from_pivotal_tracker(activity, version = :v2)
    if version == :v2
      raise ArgumentError, "no Tracker story given" unless activity && activity[:stories] && activity[:stories][:story]
      story = activity[:stories][:story]
    elsif version == :v3
      raise ArgumentError, "Tracker appears to be in old format" if activity && !activity[:stories].nil? && activity[:stories].is_a?(Hash)
      raise ArgumentError, "No Tracker story given" unless activity && activity[:stories] && !activity[:stories].empty?
      story = activity[:stories].first
    else
      raise ArgumentError, "Unrecognized version for Pivotal Tracker API"
    end
    
    task_list = self.find_by_name("Pivotal Tracker") || self.create! { |new_list|
      new_list.user = new_list.project.hook_user if new_list.project
      new_list.name = "Pivotal Tracker"
      yield new_list if block_given?
    }
    
    author = task_list.project.users.detect { |u| u.name == activity[:author] }  
    
    task = task_list.tasks.from_pivotal_tracker(story[:id]).first || task_list.tasks.build { |new_task|
      new_task.name = "#{story[:name] || activity[:description]} [PT#{story[:id]}]"
      new_task.user = author || task_list.user
    }

    task.update_from_pivotal_tracker(author, activity, version)
    return task
  end
  
  attr_accessor :reference_task_objects
  
  def references
    refs = { :users => [user_id], :projects => [project_id] }
    unless @reference_task_objects.nil?
      refs[:task_list_task] = send(@reference_task_objects)
    end
    refs
  end

  def to_s
    name
  end

  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
  end

  define_index do
    where TaskList.undeleted_clause_sql

    indexes name, :sortable => true
    has project_id, created_at, updated_at
  end

  private
    def ensure_date_order
      if start_on && finish_on && start_on > finish_on
        self.start_on, self.finish_on = finish_on, start_on
      end
    end
end
