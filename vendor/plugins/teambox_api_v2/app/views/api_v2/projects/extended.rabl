extends 'api_v2/projects/base'

attributes :organization_id, :archived
attributes :user_id => owner_user_id

code(:created_at) { |p| p.created_at.to_s(:api_time) }
code(:updated_at) { |p| p.updated_at.to_s(:api_time) }


child(:organization) { extends 'api_v2/organizations/base' }
