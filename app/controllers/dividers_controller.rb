class DividersController < ApplicationController
  before_filter :load_page
  before_filter :load_divider, :only => [:show, :edit, :update, :destroy]
  
  def new
    @divider = @page.build_divider(params[:divider])
    
    respond_to do |f|
      f.html { reload_page }
      f.m 
    end
  end
  
  def create
    calculate_position
    
    @divider = @page.build_divider(params[:divider])
    @divider.updated_by = current_user
    save_slot(@divider) if @page.editable?(current_user) && @divider.save
    
    respond_to do |f|
      if !@divider.new_record?
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
        f.js
        handle_api_success(f, @divider, true)
      else
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
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
    respond_to do |f|
      f.m
      f.js
    end
  end
  
  def update
    @divider.updated_by = current_user
    
    if @divider.editable?(current_user) and @divider.update_attributes(params[:divider])
      respond_to do |f|
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
        f.js
        handle_api_success(f, @divider)
      end
    else
      respond_to do |f|
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
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
        f.html { reload_page }
        f.m    { reload_page }
        f.js
        handle_api_success(f, @divider)
      end
    else
      respond_to do |f|
        f.html { reload_page }
        f.m    { reload_page }
        f.js
        handle_api_error(f, @divider)
      end
    end
  end
  
  private
    def load_page
      page_id = params[:page_id]
      @page = @current_project.pages.find_by_permalink(page_id) || @current_project.pages.find_by_id(page_id)
    end
    
    def reload_page(extras={})
      redirect_to project_page_path(@current_project, @page, extras)
    end
    
    def reload_edit_page(extras={})
      redirect_to edit_project_page_path(@current_project, @page, extras)
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