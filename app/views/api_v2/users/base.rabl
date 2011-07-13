attributes :id, :first_name, :last_name
code(:avatar_url) { |u| u.avatar_or_gravatar_url(:thumb) }
code(:micro_avatar_url) { |u| u.avatar_or_gravatar_url(:micro) }
extends 'api_v2/shared/type'

attributes :login => :username
