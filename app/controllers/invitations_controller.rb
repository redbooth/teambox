class InvitationsController < ApplicationController
  skip_before_filter :load_project
  before_filter :load_group_or_project
  before_filter :admins_target?, :except => [:index, :accept, :decline]
  before_filter :set_page_title
  
  def index
    if @invite_target
      if @invite_target.has_member?(current_user)
        @invited_to_project = false
      else
        # Do we have an invite?
        @invitation = @invite_target.invitations.find(:first, :conditions => {:invited_user_id => current_user.id})
        if @invitation.nil?
          if @current_group
            render :text => "You don't have permission to view this group", :status => :forbidden
          else
            render :text => "You don't have permission to view this project", :status => :forbidden
          end
          
          return
        end
      end
      
      respond_to do |f|
        f.html { 
          if @invitation
            render :action => (@current_project ? 'index_project' : 'index_group')
          else
            redirect_to @current_project ? project_people_path(@current_project) : group_path(@current_group)
          end }
      end
    else
      @invitations = current_user.invitations
      respond_to do |f|
        f.html { render :action => 'index_user' }
      end
    end
  end

  def new
    @invitation = @invite_target.invitations.new
  end
  
  def create
    if params[:login] # using a link to invite directly a user
      @user = User.find_by_login(params[:login])
      user_or_email = @user.login
      role = 2
    elsif params[:invitation]
      user_or_email = params[:invitation][:user_or_email]
      role = params[:invitation][:role] || 2
    else
      flash[:error] = t('invitations.errors.invalid')
      redirect_to target_people_path
      return
    end
    
    @invitation = @invite_target.invitations.new(:user_or_email => user_or_email.strip)
    @invitation.role = role
    @invitation.user = current_user

    respond_to do |f|
      if @invitation.save
        @user = @invitation.invited_user
        f.html { redirect_to target_people_path }
        f.m    { redirect_to target_people_path }
        f.js
      else
        flash[:error] = @invitation.errors.full_messages.first
        f.html { redirect_to target_people_path }
        f.m    { redirect_to target_people_path }
        name = @user ? @user.name : 'user' # This line is doing something?
        f.js { render :text => "alert('Error inviting #{user}. Maybe you are trying to invite an existing user.');" }
      end
    end
  end
  
  def resend
    @invitation = Invitation.find(params[:id])
    @invitation.send_email if @invitation
    respond_to{|f|f.js}
  end
  
  def destroy
    @invitation = Invitation.find(params[:id])
    if @invitation
      @invitation.destroy
    end
    respond_to{|f|f.js}
  end
  
  before_filter :load_user_invitation, :only => [ :accept, :decline ]
  skip_before_filter :belongs_to_project?, :only => [ :accept, :decline ]
  
  def accept
    @invitation.accept(current_user)
    @invitation.destroy
    if @invitation.project
      redirect_to(project_path(@invitation.project))
    else
      redirect_to(group_path(@invitation.group))
    end
  end
  
  def decline
    @invitation.destroy
    redirect_to(user_invitations_path(current_user))
  end
  
  private
    def load_group_or_project
      project_id = params[:project_id]
      group_id = params[:group_id]

      if project_id
        load_project
      elsif group_id
        load_group
      end
      
      @invite_target = @current_group || @current_project
    end
    
    def load_user_invitation
      conds = if @current_project
        { :project_id => @current_project.id,
          :invited_user_id => current_user.id}
      else
        { :group_id => @current_group.id,
          :invited_user_id => current_user.id}
      end
      
      @invitation = Invitation.find(:first,:conditions => conds)
      unless @invitation
        flash[:error] = t('invitations.errors.invalid_code')
        redirect_to user_invitations_path(current_user)
      end
    end
    
    def target
      @current_project || @current_group
    end
    
    def target_people_path
      if @current_project
        project_people_path(@current_project)
      else
        group_path(@current_group)
      end
    end

    def admins_target?
      if !(@invite_target.owner?(current_user) or @invite_target.admin?(current_user))
          respond_to do |f|
            flash[:error] = t('common.not_allowed')
            f.html {
              if @current_project
                redirect_to project_path(@current_project)
              else
                redirect_to group_path(@current_group)
              end 
            }
          end
        return false
      end
      
      true
    end
end