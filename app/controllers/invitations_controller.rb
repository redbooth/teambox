class InvitationsController < ApplicationController
  before_filter :admins_project?, :except => [:index, :accept, :decline]
  before_filter :set_page_title
  
  def index
    if @current_project
      @invitations = @current_project.invitations
      respond_to do |f|
        f.html { render :action => 'index_project' }
      end
    else
      @invitations = current_user.invitations
      respond_to do |f|
        f.html { render :action => 'index_user' }
      end
    end
  end

  def new
    @invitation = @current_project.invitations.new
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
      flash[:error] = "Invalid invitation"
      redirect_to project_people_path(@current_project)
      return
    end
    
    @invitation = @current_project.invitations.new(:user_or_email => user_or_email.strip)
    @invitation.role = role
    @invitation.user = current_user

    respond_to do |f|
      if @invitation.save
        f.html { redirect_to project_people_path(@current_project) }
        f.js
      else
        f.html do
          flash[:error] = @invitation.errors.full_messages.first
          redirect_to project_people_path(@current_project)
        end
        f.js { render :text => "alert('Error inviting #{@user.name}. Maybe you are trying to invite an existing user.');" }
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
    person = @invitation.project.people.new(
      :user => current_user,
      :role => @invitation.role || 2,
      :source_user => @invitation.user)
    person.save
    @invitation.destroy
    redirect_to(project_path(@invitation.project))
  end
  
  def decline
    @invitation.destroy
    redirect_to(user_invitations_path(current_user))
  end
  
  private
    def load_user_invitation
      @invitation = Invitation.find(:first,:conditions => {
        :project_id => @current_project.id,
        :invited_user_id => current_user.id})
      unless @invitation
        flash[:error] = "Invalid invitation code"
        redirect_to user_invitations_path(current_user)
      end
    end

    def admins_project?
      if !(@current_project.owner?(current_user) or @current_project.admin?(current_user))
          respond_to do |f|
            flash[:error] = "You are not allowed to do that!"
            f.html { redirect_to project_path(@current_project) }
          end
        return false
      end
      
      true
    end
end