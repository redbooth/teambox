class ApiV1::InvitationsController < ApiV1::APIController
  before_filter :load_target
  before_filter :belongs_to_target?
  before_filter :admins_target?, :except => [:index, :accept, :decline, :invite_format]
  before_filter :load_invite, :except => [:index]
  
  def index
    @invitations = @target.invitations.all(:conditions => api_range, :limit => api_limit)
    
    api_respond @invitations.to_json
  end

  def show
    api_respond @invitation.to_json
  end
  
  def create
    if params[:invitation] and @target != current_user
      user_or_email = params[:invitation][:user_or_email]
      role = params[:invitation][:role] || 2
      
      @targets = user_or_email.extract_emails
      @targets = user_or_email.split if @targets.empty?
      
      @invitations = @targets.map { |target| make_invitation(target, role) }
    else
      return api_error(t('invitations.errors.invalid'), :unprocessable_entity)
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
    @invitation.send(:send_email)
    
    handle_api_success(@invitation)
  end
  
  def accept
    @invitation.accept(current_user)
    @invitation.destroy
    
    handle_api_success(@invitation)
  end
  
  def destroy
    @invitation.destroy
    
    handle_api_success(@invitation)
  end

  protected

  def load_invite
    @invitation = @target.invitations.find params[:id]
  end
  
  def load_target
    if params[:project_id]
      load_project
    elsif params[:group_id]
      load_group
    end
    
    @target = @current_group || @current_project || current_user
  end
  
  def make_invitation(user_or_email, role)
    invitation = @target.invitations.new(:user_or_email => user_or_email.strip)
    invitation.role = role
    invitation.user = current_user
    @saved_count ||= 0
    @saved_count += 1 if invitation.save
    invitation
  end
  
  def belongs_to_target?
    if @current_project
      unless Person.exists?(:project_id => @current_project.id, :user_id => current_user.id)
        api_error(t('common.not_allowed'), :unauthorized)
        false
      end
    elsif @current_group
      unless @current_group.users.include? current_user
        api_error(t('common.not_allowed'), :unauthorized)
        false
      end
    end
  end
  
  def admins_target?
    if !(@target == current_user) and !(@target.owner?(current_user) or @target.admin?(current_user))
      api_error(t('common.not_allowed'), :unauthorized)
      false
    else
      true
    end
  end
  
end