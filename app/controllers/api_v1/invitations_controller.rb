class ApiV1::InvitationsController < ApiV1::APIController
  before_filter :load_target
  before_filter :load_invite, :except => [:index]
  
  def index
    authorize! :admin, @target
    @invitations = @target.invitations.all(:conditions => api_range,
                                           :limit => api_limit,
                                           :order => 'id DESC')
    
    api_respond @invitations, :include => [:project, :user], :references => [:project, :user]
  end

  def show
    authorize! :admin, @target
    api_respond @invitation, :include => [:project, :user]
  end
  
  def create
    authorize! :admin, @target
    if @target != current_user
      user_or_email = params[:user_or_email]
      role = params || Person::ROLES[:participant]
      
      @targets = user_or_email.extract_emails
      @targets = user_or_email.split if @targets.empty?
      
      @invitations = @targets.map { |target| make_invitation(target, role) }
    else
      return api_error(:unprocessable_entity, :type => 'InvalidRecord', :message => t('invitations.errors.invalid'))
    end
    
    if @saved_count > 0
      handle_api_success(f, @invitations, :is_new => true)
    else
      message = @invitations.length == 1 ? @invitations.first.errors.full_messages.first : t('people.errors.users_or_emails')
      respond_do do |f|
        f.json { render :as_json => {'error' => message}, :status => :unprocessable_entity }
      end
    end
  end
  
  def resend
    authorize! :admin, @target
    @invitation.send(:send_email)
    
    handle_api_success(@invitation)
  end
  
  def accept
    @invitation.accept(current_user)
    @invitation.destroy
    
    handle_api_success(@invitation)
  end
  
  def destroy
    authorize! :destroy, @invitation
    @invitation.destroy
    
    handle_api_success(@invitation)
  end

  protected

  def load_invite
    @invitation = @target.invitations.find params[:id]
  end
  
  def load_target
    load_project
    
    @target = @current_project || current_user
  end
  
  def make_invitation(user_or_email, role)
    invitation = @target.invitations.new(:user_or_email => user_or_email.strip)
    invitation.role = role
    invitation.user = current_user
    @saved_count ||= 0
    @saved_count += 1 if invitation.save
    invitation
  end
end