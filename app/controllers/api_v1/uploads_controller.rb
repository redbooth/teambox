class ApiV1::UploadsController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_upload, :only => [:update,:show,:destroy]
  before_filter :check_permissions, :only => [:create,:update,:destroy]
  
  def index
    @uploads = (@page || @current_project).uploads.all(
      :conditions => api_range, 
      :limit => api_limit,
      :include => [:page, :user])
    
    api_respond @uploads, :references => [:page, :user]
  end

  def show
    api_respond @upload, :include => [:page_slot]
  end
  
  def create
    @upload = @current_project.uploads.new params[:upload]
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
    @upload.destroy
    handle_api_success(@upload)
  end

  protected
  
  def load_page
    @page = @current_project.pages.find params[:page_id] if params[:page_id]
  end
  
  def load_upload
    @upload = @current_project.uploads.find(params[:id])
    api_status(:not_found) unless @upload
  end
  
end