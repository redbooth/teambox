class Public::PublicController < ApplicationController
  skip_before_filter :rss_token, :recent_projects, :touch_user, :verify_authenticity_token
  skip_before_filter :login_required
  before_filter :set_english_locale
  before_filter :load_public_projects

  layout 'public_projects'

  protected

    def set_english_locale
      I18n.locale = 'en'
    end

    def load_project
      project_id = params[:project_id] || params[:id]
      if project_id
        @project = Project.find_by_permalink(project_id)
        return render :text => 'Unexisting project' unless @project
        return render :text => 'Not a public project' unless @project.public
      end
    end

    def load_public_projects
      @projects = current_user ? current_user.projects.find_all_by_public(true) : []
    end

end