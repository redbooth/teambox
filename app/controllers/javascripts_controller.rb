class JavascriptsController < ApplicationController

  no_login_required

  before_filter :http_caching, :only => :environment

  caches_action :environment, :cache_path => lambda { |controller|
    day = controller.logged_in? && controller.current_user.first_day_of_week == 'monday' ? 1 : 0
    "i18n/environment/#{day}"
  }

  def environment
    render :layout => false, :content_type => "application/x-javascript"
  end

  protected

    def http_caching
      expires_in 14.days, :public => true
    end

end
