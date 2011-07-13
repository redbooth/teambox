attributes :id, :name
extends 'api_v2/shared/type'

child(:first_comment => :first_comment) { extends 'api_v2/comments/base' }
child(:recent_comments => :recent_comments) { extends 'api_v2/comments/base' }
