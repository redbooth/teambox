class ApiV1::SearchController < ApiV1::APIController
  before_filter :permission_to_search, :only => :index
  
  def index
    @search_terms = params[:q]
    
    unless @search_terms.blank?
      @results = ThinkingSphinx.search @search_terms,
          :retry_stale => true,
          :order => 'updated_at DESC',
          :with => { :project_id => project_ids },
          :page => params[:page],
          :classes => [Conversation, Task, TaskList, Page]
    end
    api_respond(@results||[], :emit_type => true, :references => [])
  end
  
  protected

    def permission_to_search
      unless user_can_search? or (@current_project and project_owner.can_search?)
        if Teambox.config.allow_search
          api_error :forbidden, :type => 'InsufficientPermissions', :message => 'You cannot search'
        else
          api_error :not_implemented, :type => 'ObjectNotFound', :message => 'Search is disabled'
        end
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
