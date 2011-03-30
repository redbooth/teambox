class ApiV1::DividersController < ApiV1::APIController
  before_filter :load_page
  before_filter :load_divider, :except => [:index,:create]
  
  def index
    authorize! :show, target||current_user
    
    context = if target
      target.dividers
    else
      Divider.where(:project_id => current_user.project_ids)
    end
    
    @dividers = context.where(api_range('dividers')).
                        limit(api_limit).
                        order('dividers.id DESC').
                        includes([:project, :page])
    
    api_respond @dividers, :references => [:project, :page]
  end

  def show
    authorize! :show, @divider
    api_respond @divider, :include => [:page_slot]
  end
  
  def create
    authorize! :update, @page
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
    authorize! :update, @page
    @divider.updated_by = current_user
    if @divider.update_attributes(params)
      handle_api_success(@divider)
    else
      handle_api_error(@divider)
    end
  end

  def destroy
    authorize! :update, @page
    @divider.destroy
    handle_api_success(@divider)
  end

  protected
  
  def target
    @target ||= (@page || @current_project)
  end
  
  def load_divider
    @divider = if target
      target.dividers.find_by_id(params[:id])
    else
      Divider.where(:project_id => current_user.project_ids).find_by_id(params[:id])
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Divider not found' unless @divider
  end
  
end