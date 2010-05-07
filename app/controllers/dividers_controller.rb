class DividersController < ApplicationController
  before_filter :load_page
  before_filter :load_divider, :only => [:show, :edit, :update, :destroy]
  
  def create
    calculate_position
    
    @divider = @page.build_divider(params[:divider])
    save_slot(@divider) if @page.editable?(current_user) && @divider.save
    
    respond_to do |f|
      if !@divider.new_record?
        f.js
        handle_api_success(f, @divider, true)
      else
        f.js
        handle_api_error(f, @divider)
      end
    end
  end
  
  def show
    respond_to do |f|
      f.xml { render :xml => @divider.to_xml }
      f.json{ render :as_json => @divider.to_xml }
      f.yaml{ render :as_yaml => @divider.to_xml }
    end
  end
  
  def edit
    respond_to{|f|f.js}
  end
  
  def update
    if @divider.editable?(current_user) and @divider.update_attributes(params[:divider])
      respond_to do |f|
        f.js
        handle_api_success(f, @divider)
      end
    else
      respond_to do |f|
        f.js
        handle_api_error(f, @divider)
      end
    end
  end
  
  def destroy
    @slot_id = @divider.page_slot.id
    
    if @divider.editable?(current_user)
      @divider.destroy
      respond_to do |f|
        f.js
        handle_api_success(f, @divider)
      end
    else
      respond_to do |f|
        f.js
        handle_api_error(f, @divider)
      end
    end
  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:page_id])
    end
    
    def load_divider
      begin
        @divider = @page.dividers.find(params[:id])
      rescue
        respond_to do |f|
          f.js
          handle_api_error(f, @divider)
        end
      end
    end
end