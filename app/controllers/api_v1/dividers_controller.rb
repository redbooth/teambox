class ApiV1::DividersController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_divider, :except => [:index,:create]
  before_filter :check_permissions, :only => [:create,:update,:destroy]
  
  def index
    @dividers = @page.dividers
    
    api_respond @dividers.to_json
  end

  def show
    api_respond @divider.to_json
  end
  
  def create
    calculate_position
    
    @divider = @page.build_divider(params[:divider])
    @divider.updated_by = current_user
    save_slot(@divider) if @divider.save
    
    if @divider.new_record?
      handle_api_error(@divider)
    else
      handle_api_success(@divider, :is_new => true)
    end
  end
  
  def update
    @divider.updated_by = current_user
    if @divider.update_attributes(params[:divider])
      handle_api_success(@divider)
    else
      handle_api_error(@divider)
    end
  end

  def destroy
    @divider.destroy
    handle_api_success(@divider)
  end

  protected
  
  def load_divider
    @divider = @page.dividers.find params[:id]
    api_status(:not_found) unless @divider
  end
  
end