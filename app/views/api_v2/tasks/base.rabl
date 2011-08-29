attributes :id, :name, :task_list_id, :comments_count, :assigned_id, :status, :is_private, :project_id, :hidden_comments_count
code(:due_on, :if => lambda { |t| t.due_on }) { |k| k.due_on.to_s(:db) }
extends 'api_v2/shared/type'
extends 'api_v2/shared/dates'

code(:watchers) { |c| Array.wrap(c.watcher_ids) }

child(:assigned => :assigned) { extends 'api_v2/people/base' }
child(:first_comment => :first_comment) { extends 'api_v2/comments/base' }
child(:recent_comments => :recent_comments) { extends 'api_v2/comments/base' }
child(:task_list) { extends 'api_v2/task_lists/base' }
child(:project) { extends 'api_v2/projects/base' }
child(:user) { extends 'api_v2/users/base' }
