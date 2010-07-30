class ApiV1::UploadsController < ApiV1::APIController
  before_filter :load_upload, :only => [:update,:show,:destroy]
  before_filter :check_permissions, :only => [:create,:update,:destroy]
  
  def index
    @uploads = @current_project.uploads.all(:conditions => api_range, :limit => api_limit)
    
    api_respond @uploads.to_json
  end

  def show
    api_respond @upload.to_json
  end
  
  def create
    @upload = @current_project.uploads.new params[:upload]
    @upload.user = current_user
    calculate_position if @upload.page
    @page = @upload.page

    if @upload.save
      @current_project.log_activity(@upload, 'create')
      save_slot(@upload) if @upload.page
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
  
  def load_upload
    @upload = @current_project.uploads.find(params[:id])
    api_status(:not_found) unless @upload
  end
  
end