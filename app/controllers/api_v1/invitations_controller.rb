class ApiV1::InvitationsController < ApiV1::APIController
  before_filter :load_target
  before_filter :load_invite, :except => [:index, :create]
  
  def index
    authorize! :show, @target
    authorize! :admin, @target
    
    @invitations = @target.invitations.except(:order).
                                       where(api_range('invitations')).
                                       limit(api_limit).
                                       order('invitations.id DESC')
    
    api_respond @invitations, :references => true
  end

  def show
    authorize! :show, @invitation
    authorize! :admin, @target
    api_respond @invitation, :references => true
  end
  
  def create
    authorize! :admin, @target
    if @target != current_user
      user_or_email = params[:user_or_email]
      role = params[:role] || Person::ROLES[:participant]
      membership = params[:membership] || Membership::ROLES[:external]
      
      mentions = user_or_email.gsub!(/(?:^|\W)@(\w+)/).collect{ |u| u.strip.delete('@') }
      emails = user_or_email.extract_emails!
      @targets = user_or_email.split + mentions + emails
      
      @invitations = @targets.map { |target| make_invitation(target, role, membership, params[:locale]) }
    else
      return api_error(:unprocessable_entity, :type => 'InvalidRecord', :message => t('invitations.errors.invalid'))
    end
    
    if @saved_count > 0
      handle_api_success(@invitations, :is_new => true)
    else
      message = @invitations.length == 1 ? @invitations.first.errors.full_messages.first : t('people.errors.users_or_emails')
      return api_error(:unprocessable_entity, :type => 'InvalidRecord', :message => message)
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
    @invitation = @target.invitations.find_by_id(params[:id])
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Invitation not found' unless @invitation
  end
  
  def load_target
    load_project
    
    @target = @current_project || current_user
  end
  
  def make_invitation(user_or_email, role, membership, locale)
    invitation = @target.invitations.new(:user_or_email => user_or_email.strip)
    invitation.role = role if role
    invitation.locale = locale if locale
    invitation.membership = membership if membership
    invitation.user = current_user
    @saved_count ||= 0
    @saved_count += 1 if invitation.save
    invitation
  end
end