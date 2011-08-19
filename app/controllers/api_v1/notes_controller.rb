class ApiV1::NotesController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_note, :except => [:index,:create]
  
  def index
    authorize! :show, target||current_user
    
    context = if target
      target.notes
    else
      Note.joins(:project).where(:project_id => current_user.project_ids, :projects => {:archived => false})
    end.joins(:page)
    
    @notes = context.except(:order).
                     where(['pages.is_private = ? OR (pages.is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                     joins("LEFT JOIN watchers ON (pages.id = watchers.watchable_id AND watchers.watchable_type = 'Page') AND watchers.user_id = #{current_user.id}").
                     where(api_range('notes')).
                     limit(api_limit).
                     order('notes.id DESC').
                     includes([:project, :page])
    
    api_respond @notes, :references => true
  end

  def show
    authorize! :show, @note
    api_respond @note, :references => true
  end
  
  def create
    authorize! :update, page
    @note = page.build_note(params)
    @note.updated_by = current_user
    calculate_position(@note)
    @note.save
    
    if @note.new_record?
      handle_api_error(@note)
    else
      handle_api_success(@note, :is_new => true, :references => true)
    end
  end
  
  def update
    authorize! :update, page
    @note.updated_by = current_user
    if @note.update_attributes(params)
      handle_api_success(@note, :wrap_objects => true, :references => true)
    else
      handle_api_error(@note)
    end
  end

  def destroy
    authorize! :update, page
    @note.destroy
    handle_api_success(@note)
  end

  protected
  
  def target
    @target ||= (@page || @current_project)
  end
  
  def page
    @page || @note.try(:page)
  end

  def load_note
    @note = if target
      target.notes.find_by_id(params[:id])
    else
      Note.where(:project_id => current_user.project_ids).find_by_id(params[:id])
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Note not found' unless @note
  end
  
end