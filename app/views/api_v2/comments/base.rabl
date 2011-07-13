attributes :id
extends 'api_v2/shared/type'

child(:user) { extends 'api_v2/users/base' }
child(:uploads) { extends 'api_v2/uploads/base' }

