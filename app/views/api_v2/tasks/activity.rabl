attributes :id, :name, :assigned_id
code(:type) { |t| t.class.to_s }
child(:first_comment => :first_comment) { extends 'api_v2/comments/base' }
child(:recent_comments => :recent_comments) { extends 'api_v2/comments/base' }
