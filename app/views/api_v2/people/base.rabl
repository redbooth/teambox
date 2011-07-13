attributes :id, :user_id, :role, :source_user_id
extends 'api_v2/shared/type'

child(:user) { extends 'api_v2/users/base' }
