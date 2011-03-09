class TaskListTemplate < ActiveRecord::Base
  belongs_to :organization

  before_validation :rebuild_tasks
  validates_length_of :name, :maximum => 255, :minimum => 1
  validates_presence_of :organization

  attr_accessor :titles, :descs
  attr_accessible :name, :tasks, :titles, :descs

  default_scope :order => "position asc, id desc"

  def tasks=(data=[])
    write_attribute :raw_tasks, data.to_json
  end

  def tasks
    ActiveSupport::JSON.decode(read_attribute(:raw_tasks)) || [] rescue []
  end

  def create_task_list(project, user)
    task_list = project.task_lists.new
    task_list.name = name
    task_list.user = user
    if task_list.save
      tasks.each do |task|
        task_list.tasks << Task.new(:name => task.first, :comments_attributes => [{ :body => task.second }], :user => user)
      end
    end
    task_list
  end

  def to_json(options = {})
    { :id => id,
      :name => ERB::Util.html_escape(name),
      :organization => ERB::Util.html_escape(organization.permalink),
      :tasks => tasks.collect { |t| { :title => ERB::Util.html_escape(t.first), :desc => ERB::Util.html_escape(t.second) } }
    }
  end

  protected

  def rebuild_tasks
    if titles && titles.any?
      self.tasks = titles.zip(descs || []).select { |e| e.first.present? }
    end
  end
end

