class CompleteProfileController < ActionController::Base

  protect_from_forgery

  include AuthenticatedSystem

  layout 'sessions'

  def edit
    @user = current_user
  end

  def update
    success = current_user.update_attributes(params[:user])
    if success
      # TODO: Configure password, add cuke for that
      redirect_to root_path
    else
      flash.now[:error] = t('users.update.error')
      render 'edit'
    end
  end

end
