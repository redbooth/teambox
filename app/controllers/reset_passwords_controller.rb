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
      Emailer.send_email :forgot_password, @reset_password.id
      redirect_to sent_password_path(:email => @reset_password.email)
    else
      if @reset_password.errors.on(:user)
        @reset_password.errors.clear
        flash[:error] = I18n.t('reset_passwords.create.not_found_html',
                                {:email => @reset_password.email, :support => Teambox.config.support})
      end
      render :new
    end
  end

  # Ask the user to reset password
  def reset
    begin
      @user = ResetPassword.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.current]).user
      throw ActiveRecord::RecordInvalid if @user.nil? or @user.deleted?
    rescue
      flash[:error] = I18n.t('reset_passwords.create.invalid_html', :support => Teambox.config.support)
      redirect_to login_path
    end
  end

  # Process the new password the user chose
  def update_after_forgetting
    @reset_password = ResetPassword.find_by_reset_code(params[:reset_code])

    if @reset_password and @reset_password.valid?
      @user = @reset_password.user
      @user.performing_reset = true
      @user.update_attribute :confirmed_user, true
      if @user.update_attributes(params[:user])
        @reset_password.destroy
        Emailer.send_email :reset_password, @user.id
        flash[:success] = I18n.t('reset_passwords.create.password_updated')
        self.current_user = @user
        redirect_to projects_path
      else
        flash.now[:error] = I18n.t("reset_passwords.create.password_not_updated")
        render :action => :reset, :reset_code => params[:reset_code]
      end
    else
      flash.now[:notice] = I18n.t('reset_passwords.create.invalid_html', :support => Teambox.config.support)
      @reset_password = ResetPassword.new
      render :action => :new, :reset_code => params[:reset_code]
    end
  end

end
