class SearchController < ApplicationController
  
  before_filter :permission_to_search, :only => :index
  
  def index
    @search_terms = params[:q]
    
    if @search_terms.present?

      @results = ThinkingSphinx.search @search_terms,
          :retry_stale => true,
          :order => 'updated_at DESC',
          :with => { :project_id => project_ids },
          :page => params[:page],
          :classes => [Conversation, Task, Page]

    end
  end
  
  protected
  
    def permission_to_search
      unless user_can_search? or (@current_project and project_owner.can_search?)
        flash[:notice] = "Search is disabled"
        redirect_to root_path
      end
    end
    
    def user_can_search?
      current_user.can_search?
    end
    
    def project_owner
      @current_project.user
    end
  
    def project_ids
      if @current_project
        @current_project.id
      else
        current_user.projects.collect { |p| p.id }
      end
    end

end
