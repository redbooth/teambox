attributes :id, :name, :description, :project_id
extends 'api_v2/shared/type'
child(:project) { extends 'api_v2/projects/base' }
