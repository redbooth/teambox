attributes :id, :name, :project_id
extends 'api_v2/shared/type'
extends 'api_v2/shared/dates'

child(:project) { extends 'api_v2/projects/base' }

