class NotesController < ApplicationController
  before_filter :load_page
  before_filter :load_note, :only => [:show, :edit, :update, :destroy]
  
  rescue_from CanCan::AccessDenied do |exception|
    handle_cancan_error(exception)
  end
  
  def new
    authorize! :update, @page
    @note = @page.build_note(params[:note])
    
    respond_to do |f|
      f.html { reload_page }
      f.m
    end
  end
  
  def create
    authorize! :update, @page
    @note = @page.build_note(params[:note])
    @note.updated_by = current_user
    calculate_position(@note)
    @note.save
    
    respond_to do |f|
      if !@note.new_record?
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
        f.js   { render :layout => false }
        handle_api_success(f, @note, true)
      else
        f.js   { render :layout => false }
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
        handle_api_error(f, @note)
      end
    end
  end
  
  def show
    respond_to do |f|
      f.xml { render :xml => @note.to_xml }
      f.json{ render :as_json => @note.to_xml }
      f.yaml{ render :as_yaml => @note.to_xml }
    end
  end
  
  def edit
    authorize! :update, @page
    respond_to do |f|
      f.any(:html, :m)
      f.js   { render :layout => false }
    end
  end
  
  def update
    authorize! :update, @page
    @note.updated_by = current_user
    
    if @note.editable?(current_user) and @note.update_attributes(params[:note])
      respond_to do |f|
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
        f.js   { render :layout => false }
        handle_api_success(f, @note)
      end
    else
      respond_to do |f|
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
        f.js   { render :layout => false }
        handle_api_error(f, @note)
      end
    end
  end
  
  def destroy
    @slot_id = @note.page_slot.id
    
    if can?(:destroy, @page)
      @note.destroy
      respond_to do |f|
        f.any(:html, :m) { reload_page }
        f.js   { render :layout => false }
        handle_api_success(f, @note)
      end
    else
      respond_to do |f|
        f.any(:html, :m) { reload_page }
        f.js   { render :layout => false }
        handle_api_error(f, @note)
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
    
    def load_note
      begin
        @note = @page.notes.find(params[:id])
      rescue
        respond_to do |f|
          f.js   { render :layout => false }
          handle_api_error(f, @note)
        end
      end
    end
end