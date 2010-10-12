class ApiV1::DividersController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_divider, :except => [:index,:create]
  before_filter :check_permissions, :only => [:create,:update,:destroy]
  
  def index
    query = {:include => :page}
    
    @dividers = if target
      target.dividers(query)
    else
      Divider.find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @dividers, :references => [:page]
  end

  def show
    api_respond @divider, :include => [:page_slot]
  end
  
  def create
    @divider = @page.build_divider(params)
    @divider.updated_by = current_user
    calculate_position(@divider)
    @divider.save
    
    if @divider.new_record?
      handle_api_error(@divider)
    else
      handle_api_success(@divider, :is_new => true)
    end
  end
  
  def update
    @divider.updated_by = current_user
    if @divider.update_attributes(params)
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
  
  def target
    @target ||= (@page || @current_project)
  end
  
  def load_divider
    @divider = @page.dividers.find params[:id]
    api_status(:not_found) unless @divider
  end
  
end