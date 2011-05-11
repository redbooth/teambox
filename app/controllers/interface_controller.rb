class InterfaceController < ApplicationController

  layout 'backbone'

  # Serve the Backbone main view, loading everything
  def app
    render :layout => 'backbone'
  end

end
