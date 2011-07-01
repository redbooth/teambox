attributes :id,
           :first_name,
           :last_name,
           :email,
           :locale,
           :time_zone,
           :utc_offset,
           :biography,
           :authentication_token

attributes :login => :username

%w(created_at updated_at).each do |attr|
  code(attr.to_sym) do |t|
    t.send(attr.to_sym).to_s(:api_time)
  end
end

code :avatar_url do |user|
  user.avatar_or_gravatar_url(:thumb)
end

code :micro_avatar_url do |user|
  user.avatar_or_gravatar_url(:micro)
end

code :type do |u|
  u.class.to_s
end
