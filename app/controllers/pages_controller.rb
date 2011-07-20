class PagesController < ApplicationController
  before_filter :load_page, :only => [ :show, :edit, :update, :reorder, :destroy ]
  before_filter :set_page_title
  
  rescue_from CanCan::AccessDenied do |exception|
    handle_cancan_error(exception)
  end
  
  def index
    if @current_project
      @pages = @current_project.pages
    else
      @pages = current_user.projects.collect { |p| p.pages }
    end
    
    respond_to do |f|
      f.any(:html, :m)
      f.xml { render :xml    => @pages.to_xml(:include => :slots, :root => 'pages') }
      f.json{ render :as_json => @pages.to_xml(:include => :slots, :root => 'pages') }
      f.yaml{ render :as_yaml => @pages.to_xml(:include => :slots, :root => 'pages') }
      f.rss { render :layout => false }
    end
  end
  
  def new
    authorize! :make_pages, @current_project
    @page = Page.new
    
    respond_to do |f|
      f.any(:html, :m)
    end
  end
  
  def create
    authorize! :make_pages, @current_project
    @page = @current_project.new_page(current_user,params[:page])    
    respond_to do |f|
      if @page.save
        f.any(:html, :m) { redirect_to project_page_path(@current_project,@page) }
        handle_api_success(f, @page, true)
      else
        f.any(:html, :m) { render :new }
        handle_api_error(f, @page)
      end
    end
  end
    
  def show
    @pages = @current_project.pages
    
    respond_to do |f|
      f.any(:html, :m)
      f.xml { render :xml    => @page.to_xml(:include => [:slots, :objects]) }
      f.json{ render :as_json => @page.to_xml(:include => [:slots, :objects]) }
      f.yaml{ render :as_yaml => @page.to_xml(:include => [:slots, :objects]) }
    end
  end
  
  def edit
    authorize! :update, @page
    respond_to do |f|
      f.html
      f.m   {
        @edit_part = params[:edit_part]
        if @edit_part == 'page'
          render :show
        else
          render :edit
        end
      }
    end
  end
  
  def update
    authorize! :update, @page
    respond_to do |f|
      if @page.update_attributes(params[:page])
        f.any(:html, :m)  { redirect_to project_page_path(@current_project,@page) }
        handle_api_success(f, @page)
      else
        f.any(:html, :m)  { render :edit }
        handle_api_error(f, @page)
      end
    end
  end
  
  def reorder
    authorize! :update, @page
    order = params[:slots].collect { |id| id.to_i }
    current = @page.slots.map { |slot| slot.id }
    
    # Handle orphaned elements
    # [1,3,4,5o (4),6o (5),7,8]
    # 1,4,3,8,7 NEW
    # << 1,4,3,8,7
    # insert 1,4,|5|,|6|,3,8,7
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
    
    respond_to do |f|
      f.js   { render :layout => false }
      handle_api_success(f, @page)
    end
  end
  
  def resort
    authorize! :reorder_objects, @current_project
    order = params[:pages].map(&:to_i)
    
    @current_project.pages.each do |page|
      page.suppress_activity = true
      page.position = order.index(page.id)
      page.save
    end
    
    respond_to do |f|
      f.js { render :reorder, :layout => false }
    end
  end

  def destroy
    if can? :destroy, @page
      @page.try(:destroy)

      respond_to do |f|
        flash[:success] = t('deleted.page', :name => @page.to_s)
        f.any(:html, :m)  { redirect_to project_pages_path(@current_project) }
        handle_api_success(f, @page)
      end
    else
      respond_to do |f|
        flash[:error] = t('common.not_allowed')
        f.any(:html, :m) { redirect_to project_page_path(@current_project,@page) }
        handle_api_error(f, @page)
      end
    end
  end

  private
    def load_page
      page_id = params[:id]
      @page = @current_project.pages.find_by_permalink(page_id) || @current_project.pages.find_by_id(page_id)
      
      unless @page
        flash[:error] = t('not_found.page', :id => page_id)
        redirect_to project_path(@current_project)
      end
    end
    
end