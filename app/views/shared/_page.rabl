attributes :id,
           :name,
           :description,
           :is_private,
           :project_id,
           :user_id

%w(created_at updated_at).each do |attr|
  code(attr.to_sym) do |p|
    p.send(attr.to_sym).to_s(:api_time)
  end
end

code :type do |thread|
  thread.class.to_s
end

code :watchers do |t|
  Array.wrap(t.watcher_ids)
end

code :project do |a|
  partial('shared/_project_small', :object => a.project)
end

code :user do |a|
  partial('shared/_user_small', :object => a.user)
end

