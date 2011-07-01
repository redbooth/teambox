attributes :id,
           :project_id,
           :user_id,
           :simple,
           :comments_count,
           :is_private

code :type do |c|
  c.class.to_s
end

code :name, :if => lambda {|c| !c.simple?} do |c|
  c.name
end

%w(created_at updated_at).each do |attr|
  code(attr.to_sym) do |c|
    c.send(attr.to_sym).to_s(:api_time)
  end
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

