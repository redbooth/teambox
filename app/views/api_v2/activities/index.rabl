collection @activities

attributes :id, :last_activity_id, :action, :user_id, :project_id, :target_id, :target_type, :comment_target_id, :comment_target_type, :is_private

code(:created_at) { |a| a.created_at.to_s(:api_time) }
code(:updated_at) { |a| a.updated_at.to_s(:api_time) }

code(:target) do |t|
  partial("activities/#{t.class.to_s.underscore}")
end

child(:comment_target => :comment_target) {
  code(:type) { |ct| ct.class.to_s }
  attributes :id
}

child(:user) do
  attributes :id, :first_name, :last_name, :avatar_url
  attributes :login => :username
end
child(:project) do
end

