attributes :id, :name, :project_id, :user_id, :simple, :comments_count, :is_private
extends 'api_v2/shared/type'
extends 'api_v2/shared/dates'

code(:watchers) { |c| Array.wrap(c.watcher_ids) }

child(:first_comment => :first_comment) { extends 'api_v2/comments/base' }
child(:recent_comments => :recent_comments) { extends 'api_v2/comments/base' }

# TODO add child(:comments) if required
