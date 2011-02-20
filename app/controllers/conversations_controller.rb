class ConversationsController < ApplicationController
  before_filter :load_conversation, :except => [:index, :new, :create]
  before_filter :set_page_title
  
  rescue_from CanCan::AccessDenied do |exception|
    handle_cancan_error(exception)
  end

  def new
    authorize! :converse, @current_project
    @conversation = @current_project.conversations.new
    
    respond_to do |f|
      f.any(:html, :m) { }
    end
  end

  def create
    authorize! :converse, @current_project
    @conversation = @current_project.conversations.new_by_user(current_user, params[:conversation])

    if @conversation.save
      respond_to do |f|
        f.any(:html, :m) {
          if request.xhr? or iframe?
            render :partial => 'activities/thread', :locals => {:thread => @conversation}
          else
            redirect_to current_conversation
          end
        }
        handle_api_success(f, @conversation, true)
      end
    else
      respond_to do |f|
        f.any(:html, :m) {
          if request.xhr? or iframe?
            output_errors_json(@conversation)
          else
            # TODO: display inline instead of flash
            flash.now[:error] = @conversation.errors.to_a.first
            render :action => :new
          end
        }
        handle_api_error(f, @conversation)
      end
    end
  end

  def index
    @conversations = @current_project.conversations.not_simple

    respond_to do |f|
      f.any(:html, :m)
      f.rss   { render :layout => false }
      f.xml   { render :xml     => @conversations.to_xml }
      f.json  { render :as_json => @conversations.to_xml }
      f.yaml  { render :as_yaml => @conversations.to_xml }
    end
  end

  def show
    @conversations = @current_project.conversations.not_simple

    respond_to do |f|
      f.any(:html, :m)
      f.xml   { render :xml     => @conversation.to_xml(:include => :comments) }
      f.json  { render :as_json => @conversation.to_xml(:include => :comments) }
      f.yaml  { render :as_yaml => @conversation.to_xml(:include => :comments) }
    end
  end

  def update
    authorize! :update, @conversation
    success = @conversation.update_attributes(params[:conversation])
    
    respond_to do |f|
      f.js   { head :ok }
      f.any(:html, :m) { redirect_to current_conversation }
      
      if success
        handle_api_success(f, @conversation)
      else
        handle_api_error(f, @conversation)
      end
    end
  end

  def destroy
    authorize! :destroy, @conversation
    @conversation.destroy
    
    respond_to do |f|
      f.any(:html, :m) do
        flash[:success] = t('deleted.conversation', :name => @conversation.to_s)
        redirect_to project_conversations_path(@current_project)
      end
      f.js { head :ok }
      handle_api_success(f, @conversation)
    end
  end

  def watch
    authorize! :watch, @conversation
    @conversation.add_watcher(current_user)
    
    respond_to do |f|
      f.js { render :layout => false }
      f.any(:html, :m) { redirect_to current_conversation }
    end
  end

  def unwatch
    @conversation.remove_watcher(current_user)
    
    respond_to do |f|
      f.js { render :layout => false }
      f.any(:html, :m) { redirect_to current_conversation }
    end
  end
  
  def convert_to_task
    authorize! :update, @conversation

    @conversation.attributes = params[:conversation]
    @conversation.updating_user = current_user
    @conversation.comments_attributes = {"0" => params[:comment]} if params[:comment]

    success = @conversation.save
    if success
      @task = @conversation.convert_to_task!
      success = @task && @task.errors.empty?
    end

    if success
      if request.xhr? or iframe?
        if request.referer.ends_with?(project_conversation_path(@current_project, @conversation))
          render :text => project_task_path(@current_project, @task)
        else
          render :partial => 'activities/thread', :locals => {:thread => @task}
        end
      else
        redirect_to current_conversation
      end
    else
      if request.xhr? or iframe?
        output_errors_json(@conversation)
      else
        # TODO: display inline instead of flash
        flash.now[:error] = @conversation.errors.to_a.first
        render :action => :new
      end
    end

  end

  protected
  
    def load_conversation
      @conversation = @current_project.conversations.find params[:id]
    end
    
    def current_conversation
      [@current_project, @conversation]
    end
end
