attributes :id, :last_activity_id, :action, :user_id, :project_id, :target_id, :target_type, :comment_target_id, :comment_target_type, :is_private
extends 'api_v2/shared/type'

code(:created_at) { |a| a.created_at.to_s(:api_time) }
code(:updated_at) { |a| a.updated_at.to_s(:api_time) }

code(:target, :if => lambda { |a| a.target_type}) do |a|
  partial("api_v2/#{a.target_type.pluralize.underscore}/base", :object => a.target)
end

code(:comment_target, :if => lambda { |a| a.comment_target_type}) do |a|
  partial("api_v2/#{a.comment_target_type.pluralize.underscore}/base", :object => a.comment_target)
end

child(:user) { extends 'api_v2/users/base' }
child(:project) { extends 'api_v2/projects/base' }

