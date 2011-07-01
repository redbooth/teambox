attributes :id,
           :project_id,
           :user_id,
           :task_list_id,
           :name,
           :position,
           :comments_count,
           :assigned_id,
           :status,
           :is_private,
           :record_conversion_id,
           :record_conversion_type

%w(created_at updated_at).each do |attr|
  code(attr.to_sym) do |t|
    t.send(attr.to_sym).to_s(:api_time)
  end
end

code :watchers do |t|
  Array.wrap(t.watcher_ids)
end

code :type do |thread|
  thread.class.to_s
end

code :due_on, :if => lambda {|t| t.due_on} do |t|
  t.due_on.to_s(:db)
end

code :completed_at, :if => lambda {|t| t.completed_at} do |t|
  t.completed_at.to_s(:db)
end

code :assigned do |a|
  partial('shared/_assigned', :object => a.assigned)
end

code :task_list do |a|
  partial('shared/_task_list', :object => a.task_list)
end

code :project do |a|
  partial('shared/_project_small', :object => a.project)
end

code :user do |a|
  partial('shared/_user_small', :object => a.user)
end

code :first_comment, :if => lambda {|t| t.first_comment } do |t|
  partial('shared/_comment', :object => t.first_comment)
end

code :first_comment_id, :if => lambda {|t| t.first_comment.try(:id) } do |t|
  t.first_comment.try(:id)
end

code :recent_comments do |t|
  t.recent_comments.map {|c| partial('shared/_comment', :object => c)}
end

code :recent_comment_ids do |t|
  t.recent_comments.map {|c| c.id }
end

