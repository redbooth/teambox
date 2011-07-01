attributes :id,
           :name,
           :permalink,
           :archived,
           :organization_id,
           :owner_user_id

%w(created_at updated_at).each do |attr|
  code(attr.to_sym) do |p|
    p.send(attr.to_sym).to_s(:api_time)
  end
end

code :type do |thread|
  thread.class.to_s
end

