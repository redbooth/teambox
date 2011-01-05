module CommentsHelper

  def cache_comment(comment, threaded, simpleconv, &block)
    cache(comment.cache_key.tap { |key|
      key << "-#{comment.user.avatar_updated_at.to_i}-#{comment.project.permalink}"
      key << '-threaded' if threaded
      key << '-simpleconv' if simpleconv
      key << ".#{request.format.to_sym}" if request.format.to_sym.to_s =~ /^\w+$/
    }, &block)
  end
  
  def activity_comment_user_link(comment)
    if comment.user.deleted?
      "<span class='author' style='text-decoration: line-through'>#{h comment.user.name}</span>".html_safe
    else
      content_tag :span,
        link_to(h(comment.user.name), user_path(comment.user)),
        :class => 'author'
    end
  end
  
  def activity_comment_target_link(comment, connector = "&rarr;")
    link = case comment.target_type
      when 'Conversation'
        conversation = comment.target.target
        link_to h(conversation), project_conversation_path(comment.project, conversation)
      when 'Task'
        task = comment.target.target
        link_to h(task), project_task_path(comment.project, task)
      when 'TaskList'
        task_list = comment.target.target
        link_to h(task_list), project_task_list_path(comment.project, task_list)
    end
    "<span class='arr target_arr'>#{connector}</span> <span class='target'>#{link}</span>".html_safe if link
  end

  # TODO: phase out?
  def list_comments(comments, target)
    content_tag :div, render(comments), :class => 'comments', :id => 'comments'
  end

  def comment_data(comment)
    {}.tap do |data|
      data[:'data-editable-before'] = datetime_ms(15.minutes.since(comment.created_at))
      data[:'data-user'] = comment.user.id
      data[:'data-project'] = comment.project.id
    end
  end
end