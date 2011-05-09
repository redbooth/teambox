class InvitationsController < ApplicationController
  skip_before_filter :load_project
  before_filter :load_target_project, :except => [:invite_format]
  before_filter :set_page_title
  before_filter :load_user_invitation, :only => [ :accept, :decline ]
  skip_before_filter :belongs_to_project?, :only => [ :accept, :decline ]
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |f|
      message = t('common.not_allowed')
      f.html {
        flash[:error] = message
        redirect_to project_path(@current_project)
      }
      f.js { render :text => "alert('#{message}')" }
    end
  end
  
  def index
    if @invite_target
      if @invite_target.has_member?(current_user)
        @invited_to_project = false
      else
        # Do we have an invite?
        @invitation = @invite_target.invitations.find(:first, :conditions => {:invited_user_id => current_user.id})
        if @invitation.nil?
          render :text => "You don't have permission to view this project", :status => :forbidden
          return
        end
      end
      
      respond_to do |f|
        f.any(:html, :m) {
          if @invitation
            render :action => 'index_project'
          else
            redirect_to project_people_path(@current_project)
          end }
      end
    else
      @invitations = current_user.invitations.pending_projects
      respond_to do |f|
        f.any(:html, :m) { render :action => 'index_user' }
      end
    end
  end

  def new
    authorize! :admin, @invite_target
    @invitation = @invite_target.invitations.new
    
    respond_to do |f|
      f.any(:html, :m)
    end
  end
  
  def create
    authorize! :admin, @invite_target
    if params[:invitation]
      user_or_email = params[:invitation][:user_or_email]
      params[:invitation][:role] ||= Person::ROLES[:participant]
      params[:invitation][:membership] ||= Membership::ROLES[:external]

      mentions = user_or_email.gsub!(/(?:^|\W)@(\w+)/).collect{ |u| u.strip.delete('@') }
      emails = user_or_email.extract_emails!
      @targets = user_or_email.split + mentions + emails

      @invitations = @targets.map { |target| make_invitation(target, params[:invitation], params[:invitations_locale]) }
    else
      flash[:error] = t('invitations.errors.invalid')
      redirect_to target_people_path
      return
    end
    
    respond_to do |f|
      if @invitations and @saved_count.to_i > 0
        f.any(:html, :m) { redirect_to target_people_path }
      else
        message = @invitations.length == 1 ? @invitations.first.errors.full_messages.first : 
                                             t('people.errors.users_or_emails')
        f.any(:html, :m) { flash[:error] = message; redirect_to target_people_path }
      end
    end
  end
  
  def resend
    authorize! :admin, @invite_target
    @invitation = Invitation.find_by_id params[:id]
    @invitation.send_email
    
    respond_to do |wants|
      wants.any(:html, :m) {
        flash[:notice] = t('invitations.resend.resent', :recipient => @invitation.email)
        if @invitation.project
          redirect_to project_people_path(@invitation.project)
        else
          redirect_back_or_to root_path
        end
      }
      wants.js
    end
  end
  
  def destroy
    @invitation = Invitation.find_by_id params[:id]
    authorize! :destroy, @invitation

    @invitation.destroy

    if request.xhr?
      head :ok
    else
      redirect_back_or_to root_path
    end
  end
  
  def accept
    @invitation.accept(current_user)
    @invitation.destroy
    redirect_to project_path(@invitation.project)
  end
  
  def decline
    @invitation.destroy
    redirect_to(user_invitations_path(current_user))
  end
  
  def invite_format
    render :layout => false
  end
  
  private
    def load_target_project
      load_project
      
      @invite_target = @current_project
    end
    
    def load_user_invitation
      conds = { :project_id => @current_project.id,
                :invited_user_id => current_user.id }
      
      @invitation = Invitation.find(:first,:conditions => conds)
      unless @invitation
        flash[:error] = t('invitations.errors.invalid_code')
        redirect_to user_invitations_path(current_user)
      end
    end
    
    def target
      @current_project
    end
    
    def target_people_path
      project_people_path(@current_project)
    end
    
    def make_invitation(user_or_email, params, locale)
      invitation = @invite_target.invitations.new(params.merge({:user_or_email => user_or_email.strip}))
      invitation.locale = locale
      invitation.user = current_user
      @saved_count ||= 0
      @saved_count += 1 if invitation.save
      invitation
    end

end
