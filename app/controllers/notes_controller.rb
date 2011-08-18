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
      else
        f.js   { render :layout => false }
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
      end
    end
  end
  
  def show
    render :text => ''
  end
  
  def edit
    authorize! :update, @page
    respond_to do |f|
      f.html { reload_page }
      f.m
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
      end
    else
      respond_to do |f|
        f.html { reload_page }
        f.m    { reload_edit_page(:edit_part => 'page') }
        f.js   { render :layout => false }
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
      end
    else
      @note = nil #so the template does what it should. Ugly hack but this will get deprecated and removed by teambox3.2
      respond_to do |f|
        f.any(:html, :m) { reload_page }
        f.js   { render :layout => false }
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
        end
      end
    end
end
