class DividersController < ApplicationController
  before_filter :load_page
  
  def create
    calculate_position
    
    @divider = @page.build_divider(params[:divider])
    save_slot(@divider) if @divider.save
    @divider.save
    respond_to{|f|f.js}
  end
  
  def show
    @divider = @page.dividers.find(params[:id])
    respond_to do |f|
      f.xml { render :xml => @divider.to_xml }
      f.json{ render :as_json => @divider.to_xml }
      f.yaml{ render :as_yaml => @divider.to_xml }
    end
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
    @slot_id = @divider.page_slot.id if @divider
    @divider.destroy if @divider
    respond_to{|f|f.js}    
  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:page_id])
    end
end