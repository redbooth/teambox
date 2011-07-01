attributes :id,
           :project_id,
           :user_id,
           :name,
           :simple,
           :comments_count,
           :is_private

code :type do |thread|
  thread.class.to_s
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
