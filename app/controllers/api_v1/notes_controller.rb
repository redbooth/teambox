class ApiV1::NotesController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_note, :except => [:index,:create]
  before_filter :check_permissions, :only => [:create,:update,:destroy]
  
  def index
    @notes = @page.notes
    
    api_respond @notes.to_json
  end

  def show
    api_respond @note.to_json
  end
  
  def create
    calculate_position
    
    @note = @page.build_note(params[:note])
    @note.updated_by = current_user
    save_slot(@note) if @note.save
    
    if @note.new_record?
      handle_api_error(@note)
    else
      handle_api_success(@note, :is_new => true)
    end
  end
  
  def update
    @note.updated_by = current_user
    if @note.update_attributes(params[:note])
      handle_api_success(@note)
    else
      handle_api_error(@note)
    end
  end

  def destroy
    @note.destroy
    handle_api_success(@note)
  end

  protected
  
  def load_note
    @note = @page.notes.find params[:id]
    api_status(:not_found) unless @note
  end
  
end