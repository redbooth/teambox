class NotesController < ApplicationController
  before_filter :load_page
  before_filter :load_note, :only => [:show, :edit, :update, :destroy]
  
  def create
    calculate_position
    
    @note = @page.build_note(params[:note])
    save_slot(@note) if @page.editable?(current_user) && @note.save
    
    respond_to do |f|
      if !@note.new_record?
        f.js
        handle_api_success(f, @note, true)
      else
        f.js
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
    respond_to{|f|f.js}
  end
  
  def update
    if @note.editable?(current_user) and @note.update_attributes(params[:note])
      respond_to do |f|
        f.js
        handle_api_success(f, @note)
      end
    else
      respond_to do |f|
        f.js
        handle_api_error(f, @note)
      end
    end
  end
  
  def destroy
    @slot_id = @note.page_slot.id
    
    if @note.editable?(current_user)
      @note.destroy
      respond_to do |f|
        f.js
        handle_api_success(f, @note)
      end
    else
      respond_to do |f|
        f.js
        handle_api_error(f, @note)
      end
    end
  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:page_id])
    end
    
    def load_note
      begin
        @note = @page.notes.find(params[:id])
      rescue
        respond_to do |f|
          f.js
          handle_api_error(f, @note)
        end
      end
    end
end