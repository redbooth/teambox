class ApiV1::PagesController < ApiV1::APIController
  before_filter :load_page, :only => [:show, :update, :reorder, :destroy]
  
  def index
    query = {:conditions => api_range,
             :limit => api_limit,
             :order => 'id DESC',
             :include => [:project, :user]}
    
    @pages = if @current_project
      @current_project.pages.where(api_scope).all(query)
    else
      Page.where(api_scope).find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @pages, :include => :slots, :references => [:project, :user]
  end
  
  def create
    authorize! :make_pages, @current_project
    @page = @current_project.new_page(current_user,params)
    if @page.save
      handle_api_success(@page, true)
    else
      handle_api_error(@page)
    end
  end
    
  def show
    api_respond @page, :include => [:slots, :objects]
  end
  
  def update
    authorize! :update, @page
    if @page.update_attributes(params)
      handle_api_success(@page)
    else
      handle_api_error(@page)
    end
  end
  
  def reorder
    authorize! :update, @page
    order = params[:slots].collect { |id| id.to_i }
    current = @page.slots.map { |slot| slot.id }
    
    # Handle orphaned elements
    orphans = (current - order).map { |o| 
      idx = current.index(o)
      oid = idx == 0 ? -1 : current[idx-1]
      [@page.slots[idx], oid]
    }
    
    # Insert orphans back into order list
    orphans.each { |o| order.insert(o[1], (order.index(o[0]) || -1)+1) }
    
    @page.slots.each do |slot|
      slot.position = order.index(slot.id)
      slot.save!
    end
    
    handle_api_success(@page)
  end
  
  def resort
    authorize! :reorder_objects, @current_project
    order = params[:pages].map(&:to_i)
    
    @current_project.pages.each do |page|
      page.suppress_activity = true
      page.position = order.index(page.id)
      page.save
    end
    
    handle_api_success(@page)
  end

  def destroy
    authorize! :destroy, @page
    @page.destroy

    handle_api_success(@page)
  end

  protected
  
  def load_page
    @page = if @current_project
      @current_project.pages.find(params[:id])
    else
      Page.find_by_id(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Page not found' unless @page
  end
  
  def api_scope
    conditions = {}
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    conditions
  end
end