class Public::ProjectsController < Public::PublicController

  def index
    @public_projects = Project.find_all_by_public(true, :order => 'updated_at DESC') - @projects
  end

  def show
    @activities = Activity.for_projects(@current_project).where(:is_private => false)
    @threads = @activities.threads.all(:include => [:project, :target])
    @last_activity = @threads.last
    @recent_conversations = Conversation.not_simple.where(:is_private => false).recent(11).find_all_by_project_id(@project.id)
  end

end