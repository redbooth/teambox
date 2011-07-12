attributes :id
child(:user) { extends 'api_v2/users/base' }
child(:uploads) { extends 'api_v2/uploads/base' }

