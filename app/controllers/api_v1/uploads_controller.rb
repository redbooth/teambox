class ApiV1::UploadsController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_upload, :only => [:update,:show,:destroy]
  
  def index
    query = {:conditions => api_range,
             :limit => api_limit,
             :order => 'id DESC',
             :include => [:page, :user]}
    
    @uploads = if target
      target.uploads.where(api_scope).all(query)
    else
      Upload.where(api_scope).find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @uploads, :references => [:page, :user]
  end

  def show
    api_respond @upload, :include => [:page_slot]
  end
  
  def create
    authorize! :upload_files, @current_project
    authorize! :update, @page if @page
      
    @upload = @current_project.uploads.new params
    @upload.page = @page if @page
    @upload.user = current_user
    calculate_position(@upload) if @upload.page

    if @upload.save
      @current_project.log_activity(@upload, 'create')
    end

    if @upload.new_record?
      handle_api_error(@upload)
    else
      handle_api_success(@upload, :is_new => true)
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
  
  def load_page
    @page = @current_project.pages.find params[:page_id] if params[:page_id]
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
      Upload.find_by_id(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Upload not found' unless @upload
  end
  
end