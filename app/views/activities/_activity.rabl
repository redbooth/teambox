object false
glue @activity do
  attributes :id,
             :last_activity_id,
             :action,
             :user_id,
             :target_id,
             :project_id,
             :target_type,
             :target_id,
             :action_type,
             :comment_target_id,
             :comment_target_type,
             :activity_id,
             :is_private

  code :type do |a|
    a.class.to_s
  end

  code :push_session_id, :if => lambda {|a| @push_session_id } do |a|
    @push_session_id
  end

  %w(created_at updated_at).each do |attr|
    code(attr.to_sym) do |a|
      a.send(attr.to_sym).to_s(:api_time)
    end
  end

  code :changes do |a|
    a.action_type == 'create' ? a.target.attributes : a.target.previous_changes
  end

  code :project do |a|
    partial('shared/_project_small', :object => a.project)
  end

  code :user do |a|
    partial('shared/_user_small', :object => a.user)
  end

  code :target do |t|
    case @activity.target.class.name
      when "Comment"
        partial('shared/_comment', :object => t.target)
      when "Conversation"
        partial('shared/_conversation', :object => t.target)
      when "Task"
        partial('shared/_task', :object => t.target)
      when "User"
        partial('shared/_user_small', :object => t.target)
      when "Project"
        partial('shared/_project_small', :object => t.target)
      when "Page"
        partial('shared/_page', :object => t.target)
      when "Note"
        partial('shared/_note', :object => t.target)
      when "Divider"
        partial('shared/_divider', :object => t.target)
      else
        #????
    end
  end
end
