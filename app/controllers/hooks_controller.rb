class HooksController < ApplicationController

  no_login_required
  skip_before_filter :verify_authenticity_token
  
  rescue_from ArgumentError do |exception|
    render :text => exception.message, :status => 400
  end
  
  rescue_from 'Emailer::Incoming::MissingInfo', 'Emailer::Incoming::Error' do |exception|
    logger.warn "[Emailer::Incoming] #{exception.message}"
    EmailBounce.bounce_once_per_day(exception) unless params[:from].blank?
    
    response.content_type = Mime::TEXT
    render :text => exception.message, :status => 200
  end
  
  rescue_from 'ActiveRecord::RecordInvalid' do |exception|
    if exception.message.include? "Duplicate comment"
      head :ok
    else
      raise exception
    end
  end

  def create
    case params[:hook_name]
    when 'github'
      @current_project.comments.from_github GithubIntegration::Parser.commits_with_task_ids(JSON.parse(params[:payload]))
      if params[:conversations]
        @current_project.conversations.from_github GithubIntegration::Parser.commits_without_task_ids(JSON.parse(params[:payload]))
      end
    when 'email'
      Emailer.receive_params(params)
    when 'pivotal', 'pivotal_v2'
      @current_project.task_lists.from_pivotal_tracker(params[:activity])
    when 'pivotal_v3'
      @current_project.task_lists.from_pivotal_tracker(params[:activity], :v3)
    else
      raise ArgumentError
    end

    head :ok
  end

end
