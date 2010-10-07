class ApiV1::NotesController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_note, :except => [:index,:create]
  before_filter :check_permissions, :only => [:create,:update,:destroy]
  
  def index
    query = {:include => :page}
    @notes = if target
      target.notes(query)
    else
      Note.find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @notes, :references => [:page]
  end

  def show
    api_respond @note, :include => [:page_slot]
  end
  
  def create
    @note = @page.build_note(params)
    @note.updated_by = current_user
    calculate_position(@note)
    @note.save
    
    if @note.new_record?
      handle_api_error(@note)
    else
      handle_api_success(@note, :is_new => true)
    end
  end
  
  def update
    @note.updated_by = current_user
    if @note.update_attributes(params)
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
  
  def target
    @target ||= (@page || @current_project)
  end
  
  def load_note
    @note = @page.notes.find params[:id]
    api_status(:not_found) unless @note
  end
  
end