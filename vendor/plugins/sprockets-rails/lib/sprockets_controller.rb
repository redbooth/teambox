class SprocketsController < ActionController::Base
  caches_page :show, :if => Proc.new { SprocketsApplication.use_page_caching }
  
  def show
    render :text => SprocketsApplication.source, :content_type => "text/javascript"
  end
end
