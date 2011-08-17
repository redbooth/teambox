class StaticPagesController < ApplicationController
  layout "sessions"
  skip_before_filter :login_required
  
  def goodbye
    respond_to(:html)
  end
end
