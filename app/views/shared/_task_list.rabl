attributes :id,
           :project_id,
           :user_id,
           :name,
           :position,
           :archived

code :type do |thread|
  thread.class.to_s
end

%w(created_at updated_at).each do |attr|
  code(attr.to_sym) do |tl|
    tl.send(attr.to_sym).to_s(:api_time)
  end
end

code :type do |thread|
  thread.class.to_s
end

code :start_on, :if => lambda {|tl| tl.start_on} do |tl|
  tl.start_on.to_s(:db)
end

code :finish_on, :if => lambda {|tl| tl.finish_on} do |tl|
  tl.finish_on.to_s(:db)
end

code :completed_at, :if => lambda {|tl| tl.completed_at} do |tl|
  tl.completed_at.to_s(:db)
end
