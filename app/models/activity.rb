class Activity < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :user
  belongs_to :project
  acts_as_paranoid

  named_scope :for_task_lists, :conditions => "target_type = 'TaskList' || target_type = 'Task' || comment_target_type = 'TaskList' || comment_target_type = 'Task'"
  named_scope :for_conversations, :conditions => "target_type = 'Conversation' || comment_target_type = 'Conversation'"
  
  named_scope :latest, :order => 'id DESC', :limit => Teambox.config.activities_per_page

  named_scope :in_projects, lambda { |projects| { :conditions => ["project_id IN (?)", Array(projects).collect(&:id) ] } }
  named_scope :limit_per_page, :limit => APP_CONFIG['activities_per_page']
  named_scope :by_id, :order => 'id DESC'
  named_scope :by_updated, :order => 'updated_at desc'
  named_scope :threads, :conditions => "target_type != 'Comment'"
  named_scope :before, lambda { |activity_id| { :conditions => ["id < ?", activity_id ] } }
  named_scope :after, lambda { |activity_id| { :conditions => ["id > ?", activity_id ] } }
  named_scope :from_user, lambda { |user| { :conditions => { :user_id => user.id } } }

  def self.log(project,target,action,creator_id)
    project_id = project.try(:id)

    if target.is_a? Comment
      comment_target_type = target.target_type
      comment_target_id = target.target_id
      # touch activity related to that comment's thread
      Activity.last(:conditions => ["target_type = ? AND target_id = ?", comment_target_type, comment_target_id]).try(:touch)
    end
        
    activity = Activity.new(
      :project_id => project_id,
      :target => target,
      :action => action,
      :user_id => creator_id,
      :comment_target_type => comment_target_type,
      :comment_target_id => comment_target_id)
    activity.created_at = target.try(:created_at) || nil
    activity.save
    
    activity
  end

  def action_comment_type
    i = "#{action}#{target_type}"
    i +="#{comment_target_type}" if comment_target_type
    i.underscore
  end


  def action_type
    i = "#{action}#{target_type}"
    i.underscore
  end
    
  def action_type?(current_type)
    i = "#{action}#{target_type.singular_class_name}"
    i.underscore
    i == current_type
  end
  
  def user
    target.user
  end

  def posted_date
    target.created_at
  end

  def deleted_date
    target.deleted_at
  end

  def downcase_type
    target.type.to_s.downcase
  end

  def target
    case target_type
    when 'Person'       then begin; Person.find_with_deleted(target_id); rescue; nil; end
    when 'Comment'      then begin; Comment.find_with_deleted(target_id); rescue; nil; end
    when 'Conversation' then begin; Conversation.find_with_deleted(target_id); rescue; nil; end
    when 'TaskList'     then begin; TaskList.find_with_deleted(target_id); rescue; nil; end
    when 'Task'         then begin; Task.find_with_deleted(target_id); rescue; nil; end
    when 'Page'         then begin; Page.find_with_deleted(target_id); rescue; nil; end
    when 'Note'         then begin; Note.find_with_deleted(target_id); rescue; nil; end
    when 'Divider'      then begin; Divider.find_with_deleted(target_id); rescue; nil; end
    when 'Upload'       then begin; Upload.find_with_deleted(target_id); rescue; nil; end
    when 'Project'      then begin; Project.find_with_deleted(target_id); rescue; nil; end
    end
  end

  def user
    @user ||= User.find_with_deleted(user_id)
  end

  def thread
    @thread ||= if target.is_a?(Comment)
      target.target
    else
      target
    end || project
  end

  def thread_id
    target_type == 'Comment' ? "#{comment_target_type}_#{comment_target_id}" : "#{target_type}_#{target_id}"
  end

  def self.for_projects(projects)
    in_projects(projects).limit_per_page.by_updated
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]

    xml.activity :id => id do
      xml.tag! 'action', action
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)

      xml.user :id => user_id do
        xml.tag! 'username',   user.login
        xml.tag! 'first-name', user.first_name
        xml.tag! 'last-name',  user.last_name
        xml.tag! 'avatar-url', user.avatar_or_gravatar_url(:thumb)
      end

      xml.project :id => project_id do
        xml.tag! 'name',       project.name
        xml.tag! 'permalink',  project.permalink
      end

      xml.target :id => target.id do
        xml.tag! 'type', target.class
        target.to_xml(options.merge({ :skip_instruct => true }))
      end if target
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :action => action,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :user_id => user_id,
      :project_id => project_id,
      :target_id => target_id,
      :target_type => target_type
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :project
      base[:project] = {:name => project.name, :permalink => project.permalink}
    end
    
    if Array(options[:include]).include? :target
      base[:target] = target.to_api_hash
    end
    
    if Array(options[:include]).include? :user
      base[:user] = {
        :username => user.login,
        :first_name => user.first_name,
        :last_name => user.last_name,
        :avatar_url => user.avatar_or_gravatar_url(:thumb)
      }
    end
    
    base
  end

end