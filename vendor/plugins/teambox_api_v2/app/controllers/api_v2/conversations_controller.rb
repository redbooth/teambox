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

    if (value = $redis.get(redis_key))
      logger.info "[Redis] get(#{redis_key})"
      json = value
    else
      @conversations = conversation_context.
                       except(:order).
                       where(api_range('conversations')).
                       where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                       joins("LEFT JOIN watchers ON (conversations.id = watchers.watchable_id AND watchers.watchable_type = 'Conversation') AND watchers.user_id = #{current_user.id}").
                       limit(api_limit).
                       order('conversations.id DESC')
      json = render_to_string
      $redis.set(redis_key, json)
      logger.info "[Redis] set(#{redis_key})"
    end

    render :text => json
  end

  private

  def redis_key
    request.path.parameterize
  end

  def context
    @current_project || current_user
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

    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end

    conditions
  end

end
