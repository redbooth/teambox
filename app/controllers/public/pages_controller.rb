class Public::PagesController < Public::PublicController

  def index
    @pages = @project.pages
  end

  def show
    load_page
  end

  protected

    def load_page
      @page = @project.pages.find_by_id(params[:id]) || @project.pages.find_by_permalink(params[:id])

      unless @page
        flash[:error] = t('not_found.page', :id => params[:id])
        redirect_to public_project_path(@project)
      end
    end


end