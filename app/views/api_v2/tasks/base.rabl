attributes :id, :name, :task_list_id, :comments_count, :assigned_id, :status, :is_private
extends 'api_v2/shared/type'
extends 'api_v2/shared/dates'

child(:first_comment => :first_comment) { extends 'api_v2/comments/base' }
child(:recent_comments => :recent_comments) { extends 'api_v2/comments/base' }
