class ApiV1::PagesController < ApiV1::APIController
  before_filter :load_page, :only => [:show, :update, :reorder, :destroy]
  before_filter :check_permissions, :only => [:create,:update,:reorder,:resort,:destroy]
  
  def index
    query = {:conditions => api_range, :limit => api_limit, :order => 'id ASC', :include => [:project, :user]}
    
    @pages = if @current_project
      @current_project.pages.scoped(api_scope).all(query)
    else
      Page.scoped(api_scope).find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @pages, :include => :slots, :references => [:user]
  end
  
  def create
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
    if @page.update_attributes(params)
      handle_api_success(@page)
    else
      handle_api_error(@page)
    end
  end
  
  def reorder
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
    order = params[:pages].map(&:to_i)
    
    @current_project.pages.each do |page|
      page.suppress_activity = true
      page.position = order.index(page.id)
      page.save
    end
    
    handle_api_success(@page)
  end

  def destroy
    @page.destroy

    handle_api_success(@page)
  end

  protected
  
  def api_scope
    conditions = {}
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    {:conditions => conditions}
  end
  
  def load_page
    @page = if @current_project
      @current_project.pages.find params[:id]
    else
      Page.find_by_id(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_status(:not_found) unless @page
  end  
end