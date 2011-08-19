class ApiV1::ConversationsController < ApiV1::APIController
  before_filter :load_conversation, :except => [:index, :create]
  
  def index
    authorize! :show, @current_project||current_user
    
    context = if @current_project
      @current_project.conversations.where(api_scope)
    else
      Conversation.joins(:project).where(:project_id => current_user.project_ids, :projects => {:archived => false}).where(api_scope)
    end
    
    @conversations = context.except(:order).
                             where(api_range('conversations')).
                             where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                             joins("LEFT JOIN watchers ON (conversations.id = watchers.watchable_id AND watchers.watchable_type = 'Conversation') AND watchers.user_id = #{current_user.id}").
                             limit(api_limit).
                             order('conversations.id DESC')
    
    api_respond @conversations, :references => true
  end

  def show
    authorize! :show, @conversation
    api_respond @conversation, :include => api_include, :references => true
  end
  
  def create
    authorize! :converse, @current_project
    @conversation = @current_project.conversations.new_by_user(current_user, params)
    @conversation.is_private = (params[:conversation][:is_private]||false) if params[:conversation]
    
    if @conversation.save
      handle_api_success(@conversation, :is_new => true, :references => true, :include => [:user, :uploads, :google_docs])
    else
      handle_api_error(@conversation)
    end
  end
  
  def update
    authorize! :update, @conversation

    @conversation.updating_user = current_user

    if @conversation.update_attributes params
      handle_api_success(@conversation, :wrap_objects => true, :references => true, :include => [:user, :uploads, :google_docs])
    else
      handle_api_error(@conversation)
    end
  end

  def destroy
    authorize! :destroy, @conversation
    @conversation.destroy
    handle_api_success(@conversation)
  end
  
  def convert_to_task
    authorize! :update, @conversation

    @conversation.attributes = params
    @conversation.updating_user = current_user
    @conversation.comments_attributes = {"0" => params[:comment]} if params[:comment]

    success = @conversation.save
    if success
      @task = @conversation.convert_to_task!
      success = @task && @task.errors.empty?
    end

    if success
      handle_api_success(@task, :is_new => true, :include => [:comments])
    else
      handle_api_error(@task||@conversation)
    end
  end
  
  def watch
    authorize! :update, @conversation
    @conversation.add_watcher(current_user)
    handle_api_success(@conversation)
  end

  def unwatch
    authorize! :update, @conversation
    @conversation.remove_watcher(current_user)
    handle_api_success(@conversation)
  end

  protected
  
  def load_conversation
    @conversation = if @current_project
      @current_project.conversations.find_by_id(params[:id])
    else
      Conversation.where(:project_id => current_user.project_ids).find_by_id(params[:id])
    end
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Conversation not found' unless @conversation
  end
  
  def api_scope
    conditions = {}
    if params[:type]
      case params[:type]
      when 'thread'
        conditions[:simple] = true
      when 'conversation'
        conditions[:simple] = false
      end
    end
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    conditions
  end
  
  def add_watchers(hash)
    (hash || []).each do |user_id, should_notify|
      if should_notify == "1" and Person.exists? :project_id => @conversation.project_id, :user_id => user_id
        user = User.find user_id
        @conversation.add_watcher user# if user
      end
    end
  end
    
  def api_include
    [:comments, :user, :uploads] & (params[:include]||{}).map(&:to_sym)
  end
  
end

