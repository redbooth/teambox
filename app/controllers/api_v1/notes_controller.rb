class ApiV1::NotesController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_note, :except => [:index,:create]
  
  def index
    query = {:conditions => api_range,
             :limit => api_limit,
             :order => 'id DESC',
             :include => [:project, :page]}
    
    @notes = if target
      target.notes.all(query)
    else
      Note.find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @notes, :references => [:project, :page]
  end

  def show
    api_respond @note, :include => [:page_slot]
  end
  
  def create
    authorize! :update, @page
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
    authorize! :update, @page
    @note.updated_by = current_user
    if @note.update_attributes(params)
      handle_api_success(@note)
    else
      handle_api_error(@note)
    end
  end

  def destroy
    authorize! :update, @page
    @note.destroy
    handle_api_success(@note)
  end

  protected
  
  def target
    @target ||= (@page || @current_project)
  end
  
  def load_note
    @note = if target
      target.notes.find params[:id]
    else
      Note.find_by_id(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Note not found' unless @note
  end
  
end