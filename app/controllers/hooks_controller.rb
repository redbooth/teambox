class HooksController < ApplicationController

  no_login_required
  skip_before_filter :verify_authenticity_token
  
  rescue_from ArgumentError do |exception|
    render :text => exception.message, :status => 400
  end

  def create
    case params[:hook_name]
    when 'github'
      @current_project.conversations.from_github JSON.parse(params[:payload])
    when 'email'
      Emailer.receive_params(params)
    when 'pivotal'
      @current_project.task_lists.from_pivotal_tracker(params[:activity])
    else
      raise ArgumentError
    end

    head :ok
  end

end