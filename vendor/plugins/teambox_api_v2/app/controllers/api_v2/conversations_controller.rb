class ApiV2::ConversationsController < ApiV2::BaseController

  before_filter :load_conversation, :except => [:index, :create]

  ##
  # Paths:
  #   - /api/2/conversations
  #   - /api/2/projects/:project_id/conversations
  #
  # Response: 200
  #
  def index
    authorize!(:show, context)
    @conversations = conversation_context.
                     except(:order).
                     where(api_range('conversations')).
                     where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                     joins("LEFT JOIN watchers ON (conversations.id = watchers.watchable_id AND watchers.watchable_type = 'Conversation') AND watchers.user_id = #{current_user.id}").
                     limit(api_limit).
                     order('conversations.id DESC')
  end

  ##
  # Paths:
  #   - /api/2/conversations/:id
  #
  def show
    authorize!(:show, @conversation)
  end

  def create
    authorize!(:converse, @current_project)
    @conversation = @current_project.conversations.new_by_user(current_user, params)
    @conversation.is_private = (params[:conversation][:is_private] || false) if params[:conversation]

    if @conversation.save
      render 'show', :status => :created
    else
      render 'errors', :status => :unprocessable_entity
    end
  end

  def update
    authorize!(:update, @conversation)

    @conversation.updating_user = current_user

    if @conversation.update_attributes params
      render 'show'
    else
      render 'errors', :status => :unprocessable_entity
    end
  end

  def destroy
    authorize!(:destroy, @conversation)
    @conversation.destroy
    render :nothing => true, :status => 204
  end

  def convert_to_task
    authorize!(:update, @conversation)

    @conversation.attributes = params
    @conversation.updating_user = current_user
    @conversation.comments_attributes = {"0" => params[:comment]} if params[:comment]

    if @conversation.save
      @task = @conversation.convert_to_task!
      if @task && @task.errors.empty?
        render 'api_v2/tasks/show'
      else
        render 'api_v2/tasks/errors', :status => :unprocessable_entity
      end
    else
      render 'errors', :status => :unprocessable_entity
    end
  end

  private

  def load_conversation
    scope = Conversation.where(:project_id => current_user.project_ids)
    @conversation = scope.find(params[:id])
  end

  def context
    @context = @current_project || current_user
  end

  def conversation_context
    scope = if @current_project
              @current_project.conversations
            else
              Conversation.where(:project_id => current_user.project_ids)
            end

    scope.where(api_scope)
  end

  def api_scope
    conditions = {}

    if params[:type]
      conditions[:simple] = case params[:type]
                            when 'thread' then true
                            when 'conversation' then false
                            end
    end

    conditions[:user_id] = params[:user_id].to_i if params[:user_id]

    conditions
  end

end
