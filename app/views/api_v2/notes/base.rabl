attributes :id, :name, :body, :body_html, :page_id, :project_id
extends 'api_v2/shared/type'

code(:slot_id) { |n| n.page_slot.id }
child(:project) { extends 'api_v2/projects/base' }
