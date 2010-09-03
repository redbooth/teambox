class ResetPasswordsController < ApplicationController
  no_login_required
  
  before_filter :set_page_title
  layout "sessions"
  
  def new
    @reset_password = ResetPassword.new
  end

  def create
    @reset_password = ResetPassword.new(params[:reset_password])
    @reset_password.user = User.find_by_email(@reset_password.email)
    
    if @reset_password.save
      flash[:error] = nil
      Emailer.deliver_forgot_password(@reset_password)
      redirect_to sent_password_path(:email => @reset_password.email)
    else
      if @reset_password.errors.on(:user)
        @reset_password.errors.clear
        flash[:error] = I18n.t('reset_passwords.create.not_found',
                                {:email => @reset_password.email, :support => APP_CONFIG['support']})
      end
      render :new
    end
  end

  def reset
    begin
      @user = ResetPassword.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.current]).user
      throw ActiveRecord::RecordInvalid if @user.nil? or @user.deleted?
    rescue
      flash[:error] = I18n.t('reset_passwords.create.invalid', :support => APP_CONFIG['support'])
      redirect_to login_path
    end
  end

  def update_after_forgetting
    @reset_password = ResetPassword.find_by_reset_code(params[:reset_code])
    
    if @reset_password and @reset_password.valid?
      @user = @reset_password.user
      @user.performing_reset = true
      if @user.update_attributes(params[:user])
        @reset_password.destroy
        Emailer.deliver_reset_password(@user)
        flash[:success] = I18n.t('reset_passwords.create.password_updated')
        self.current_user = @user
        redirect_to projects_path
      else
        flash.now[:error] = I18n.t("reset_passwords.create.password_not_updated")
        render :action => :reset, :reset_code => params[:reset_code]
      end
    else
      flash.now[:notice] = I18n.t('reset_passwords.create.invalid', :support => APP_CONFIG['support'])
      @reset_password = ResetPassword.new
      render :action => :new, :reset_code => params[:reset_code]
    end
  end
  
end
