class GroupsController < ApplicationController
  skip_before_filter :load_project
  before_filter :check_groups
  before_filter :load_group, :except => [:index, :new, :create]
  before_filter :check_admin, :only => [:projects, :members]
  before_filter :check_edit, :only => [:edit, :update, :destroy]
  before_filter :set_page_title
  
  def index
    @group = current_user.group
    @groups = current_user.groups
    @groups_member = @groups - [@group]
  end
  
  def show
    @contacts = []
    @invitations = Invitation.find(:all, :conditions => {:group_id => @group.id})
  end
  
  def new
    @group = Group.new
  end
  
  def create
    unless current_user.group.nil?
      flash[:error] = t('groups.errors.already_own')
      redirect_to groups_path
      return
    end
    
    @group = Group.new(params[:group])
    @group.user = current_user
    
    respond_to do |f|
      if @group.save
        flash[:notice] = I18n.t('groups.new.created')
        f.html { redirect_to group_path(@group) }
      else
        flash[:error] = I18n.t('groups.new.invalid_group')
        f.html { render :new }
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @group.update_attributes(params[:group])
        if params[:only_logo]
          f.html { logo }
        else
          f.html { redirect_to group_path(@group) }
        end
      else  
        flash[:error] = I18n.t('groups.new.invalid_group')
        if params[:only_logo]
          f.html { logo }
        else
          f.html { render :new }
        end
      end
    end
  end
  
  def destroy
    @group.destroy
    respond_to do |f|
      f.html { redirect_to groups_path }
    end
  end
  
  def logo
    case request.method
    when :delete
      @group.logo = nil
      @group.save!
    end
    render :logo, :layout => 'upload_iframe'
  end
  
  def projects
    saved = false
    list = (params[:group][:project_ids] || []) rescue []
    list = list.map(&:to_i)
    
    # Filter out projects we don't own
    projects = current_user.projects.find(:all, :conditions => {:id => list, :user_id => current_user.id})
    list = projects.map(&:id)
    
    case request.method
    when :put
      @group.project_ids = (@group.project_ids + list).uniq
      saved = @group.save
    when :post
      saved = false
    when :delete
      @group.project_ids = @group.project_ids - list
      saved = @group.save
    end
    
    respond_to do |f|
      f.html {redirect_to group_path(@group)}
      f.js {@projects = @group.projects}
    end
  end

  def members
    saved = false
    list = (params[:group][:member_ids] || []) rescue []
    list = list.map(&:to_i)
    
    case request.method
    when :delete
      @removed_member_ids = @group.user_ids & list
      @group.user_ids = @group.user_ids - list
      saved = @group.save
    end
    
    respond_to do |f|
      f.html {redirect_to group_path(@group)}
      f.js {@members = @group.users}
    end
  end
  
private

  def check_groups
    # No groups? bah!
    unless groups_enabled?
      flash[:error] = t('groups.errors.not_enabled')
      redirect_to root_path
      return false
    end
  end
  
  def check_admin
    unless @group.admin?(current_user)
      flash[:error] = t('groups.errors.not_admin')
      redirect_to root_path
      return false
    end
  end
  
  def check_edit
    unless @group.owner?(current_user)
      flash[:error] = t('groups.errors.no_edit')
      redirect_to root_path
      return false
    end
  end
  
  def load_group
    # No groups? bah!
    unless groups_enabled?
      flash[:error] = t('groups.errors.not_enabled')
      redirect_to root_path
      return false
    end
    
    @group = current_user.groups.find_by_permalink(params[:id])
    unless @group
      flash[:error] = t('not_found.group', :id => params[:id])
      redirect_to groups_path
      return false
    end
  end

end
