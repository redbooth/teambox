class TaskList < RoleRecord
  include Immortal

  include Watchable

  attr_accessible :name, :start_on, :finish_on

  concerned_with :validation,
                 :initializers,
                 :scopes,
                 :associations,
                 :callbacks,
                 :conversions

  before_save :ensure_date_order
  
  def self.from_pivotal_tracker(activity)
    unless activity and activity[:stories] and activity[:stories][:story]
      raise ArgumentError, "no Tracker story given"
    end
    
    story = activity[:stories][:story]
    
    task_list = self.find_by_name("Pivotal Tracker") || self.create! { |new_list|
      new_list.user = new_list.project.user if new_list.project
      new_list.name = "Pivotal Tracker"
      yield new_list if block_given?
    }
    
    author = task_list.project.users.detect { |u| u.name == activity[:author] }  
    
    task = task_list.tasks.from_pivotal_tracker(story[:id]).first || task_list.tasks.build { |new_task|
      new_task.name = "#{story[:name]} [PT#{story[:id]}]"
      new_task.user = author || task_list.user
    }

    task.update_from_pivotal_tracker(author, activity)
    return task
  end

  def to_s
    name
  end

  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
  end

  define_index do
    where "`task_lists`.`deleted` = 0"

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