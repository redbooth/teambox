class DividersController < ApplicationController
  before_filter :load_page
  
  def create
    @divider = @page.build_divider(params[:divider])
    @divider.save
    respond_to{|f|f.js}
  end
  
  def edit
    @divider = @page.dividers.find(params[:id])
    respond_to{|f|f.js}
  end
  
  def update
    @divider = @page.dividers.find(params[:id])
    @divider.update_attributes(params[:divider])
    respond_to{|f|f.js}
  end
  
  def destroy
    @divider = @page.dividers.find(params[:id])
    @divider.destroy if @divider
    respond_to{|f|f.js}    
  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:page_id])
    end
end