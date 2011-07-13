attributes :id, :body, :body_html, :user_id, :project_id, :target_id, :target_type, :hours, :upload_ids, :google_doc_ids, :recent_projects_ids
attributes :assigned_id, :previous_assigned_id, :status, :previous_status, :due_on, :previous_due_on
extends 'api_v2/shared/type'

code(:created_at) { |a| a.created_at.to_s(:api_time) }
code(:updated_at) { |a| a.updated_at.to_s(:api_time) }

# FIXME missing target

child(:user) { extends 'api_v2/users/base' }
child(:uploads) { extends 'api_v2/uploads/base' }
child(:google_docs) { extends 'api_v2/google_docs/base' } # FIXME implement view
child(:assigned => :assigned) { extends 'api_v2/people/base' }

