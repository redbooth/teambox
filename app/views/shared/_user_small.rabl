attributes :id, :first_name, :last_name
attributes :login => :username

code :avatar_url do |user|
  user.avatar_or_gravatar_url(:thumb)
end

code :micro_avatar_url do |user|
  user.avatar_or_gravatar_url(:micro)
end
