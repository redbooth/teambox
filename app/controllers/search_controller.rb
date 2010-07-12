class SearchController < ApplicationController
  
  def results
    unless current_user.can_search?
      flash[:error] = "Search has been disabled"
      redirect_to root_path
      return
    end

    @search_page = params[:page]
    @search = params[:search]
    @comments = Comment.search(
                  @search,
                  :retry_stale => true,
                  :order => 'created_at DESC',
                  :with => { :project_id => my_project_ids },
                  :page => @search_page)
  end
  
  protected
  
    def my_project_ids
      current_user.projects.collect { |p| p.id }
    end
end