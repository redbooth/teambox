class Public::ProjectsController < Public::PublicController

  def index
    @public_projects = Project.find_all_by_public(true, :order => 'updated_at DESC') - @projects
  end

  def show
    @activities = Project.get_activities_for @project
    @last_activity = @activities.last
    @recent_conversations = Conversation.not_simple.recent(11).find_all_by_project_id(@project.id)

    @threads = Activity.get_threads(@activities)
  end

end