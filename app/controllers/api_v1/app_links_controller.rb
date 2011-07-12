class ApiV1::AppLinksController < ApiV1::APIController
  before_filter :load_app_link, :except => [:index, :create]

  def index
    authorize! :show, current_user
    
    @app_links = current_user.app_links.except(:order).
                             where(api_range('app_links')).
                             limit(api_limit).
                             order('app_links.id DESC')
    
    api_respond @app_links, :references => true
  end

  def show
    authorize! :show, @app_link
    api_respond @app_link, :references => true, :include => api_include
  end
  
  def create
    authorize! :admin, current_user
    @app_link = current_user.app_links.new(params)

    if @app_link.save
      handle_api_success(@app_link, :is_new => true)
    else
      handle_api_error(@app_link)
    end
  end

  def destroy
    authorize! :destroy, @app_link
    @app_link.destroy
    handle_api_success(@app_link)
  end

  protected

  def load_app_link
    app_link_id = params[:id]

    if app_link_id
      @app_link = AppLink.find_by_id(app_link_id)
      api_error :not_found, :type => 'ObjectNotFound', :message => 'AppLink not found' unless @app_link
    end
  end

  def api_include
    (params[:include]||{}).map(&:to_sym)
  end
 
end
