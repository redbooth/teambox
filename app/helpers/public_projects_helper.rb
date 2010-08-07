module PublicProjectsHelper

  def seo_public_project_conversation_path(project, conversation)
    route = "#{conversation.id}-#{conversation.name.parameterize}"
    public_project_conversation_path(project, route)
  end
end