class Public::PagesController < Public::PublicController

  def index
    @pages = @project.pages
  end

  def show
    load_page
  end

  protected

    def load_page
      begin
        @page = @project.pages.find(params[:id])
      rescue
        flash[:error] = t('not_found.page', :id => params[:id])
      end
    
      redirect_to public_project_path(@project) unless @page
    end


end