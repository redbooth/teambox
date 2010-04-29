class SprocketsController < ActionController::Base
  caches_page :index, :show, :if => Proc.new { SprocketsApplication.use_page_caching }
  
  def index
    show
  end

  def show
    expires_in 6.hours, :public => true

    sprocket = Sprocket.new(params[:id])

    if stale?(:last_modified => sprocket.send(:secretary).source_last_modified.utc)
      render :text => sprocket.source, :content_type => 'text/javascript'
    end
  end
end
