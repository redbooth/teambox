class SearchController < ApplicationController
  
  def results
    @comments = Comment.search(
                  params[:search],
                  :retry_stale => true,
                  :order => 'created_at DESC',
                  :with => { :project_id => my_project_ids }).compact
  end
  
  protected
  
    def my_project_ids
      current_user.projects.collect { |p| p.id }
    end
end