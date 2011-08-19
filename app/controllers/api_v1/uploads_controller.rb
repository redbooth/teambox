class ApiV1::UploadsController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_upload, :only => [:update,:show,:destroy]
  
  def index
    authorize! :show, target||current_user
    
    context = if target
      target.uploads.where(api_scope)
    else
      Upload.joins(:project).where(:project_id => current_user.project_ids, :projects => {:archived => false}).where(api_scope)
    end
    
    @uploads = context.except(:order).
                       where(api_range('uploads')).
                       where(['uploads.is_private = ? OR (uploads.is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                       joins("LEFT JOIN comments ON comments.id = uploads.comment_id").
                       joins("LEFT JOIN watchers ON (comments.target_id = watchers.watchable_id AND watchers.watchable_type = comments.target_type) AND watchers.user_id = #{current_user.id}"). 
                       limit(api_limit).
                       order('uploads.id DESC').
                       includes([:page, :user])
    
    api_respond @uploads, :references => true
  end

  def show
    authorize! :show, @upload
    api_respond @upload, :references => true
  end
  
  def create
    authorize! :upload_files, @current_project
    authorize! :update, page if page
      
    @upload = @current_project.uploads.new params
    @upload.page = page if page
    @upload.user = current_user
    calculate_position(@upload) if @upload.page

    if @upload.save
      @current_project.log_activity(@upload, 'create')
    end

    if @upload.new_record?
      handle_api_error(@upload)
    else
      handle_api_success(@upload, :is_new => true, :references => true)
    end
  end

  def destroy
    authorize! :destroy, @upload
    @upload.destroy
    handle_api_success(@upload)
  end

  protected
  
  def target
    @target ||= (@page || @current_project)
  end
  
  def page
    @page || @upload.try(:page)
  end

  def load_page
    return unless params[:page_id]
    @page = @current_project.pages.find_by_id(params[:page_id])
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Page not found' unless @page
  end
  
  def api_scope
    conditions = {}
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    conditions
  end
  
  def load_upload
    @upload = if target
      target.uploads.find(params[:id])
    else
      Upload.where(:project_id => current_user.project_ids).find_by_id(params[:id])
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Upload not found' unless @upload
  end
  
end