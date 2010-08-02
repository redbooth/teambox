class Public::PublicController < ApplicationController
  skip_before_filter :rss_token, :recent_projects, :touch_user, :verify_authenticity_token
  skip_before_filter :login_required
  before_filter :set_english_locale

  layout 'public_projects'

  protected

    def set_english_locale
      I18n.locale = 'en'
    end

    def load_project
      project_id = params[:project_id] || params[:id]
      if project_id
        @project = Project.find_by_permalink(project_id)
        render :text => 'Unexisting project' unless @project
        render :text => 'Not a public project' unless @project.try(:public)
      end
    end

end