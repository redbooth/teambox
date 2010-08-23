module CommentsHelper

  def cache_editable_comment(comment, threaded, simpleconv, &block)
    cache(comment.cache_key.tap { |key|
      key << "-#{comment.user.avatar_updated_at.to_i}-#{comment.project.permalink}"
      key << '-editable' if can?(:edit, comment)
      key << '-destructable' if can?(:destroy, comment)
      key << '-threaded' if threaded
      key << '-simpleconv' if simpleconv
      key << ".#{request.format}"
    }, &block)
  end
  
  def activity_comment_user_link(comment)
    if comment.user.deleted_at
      "<span class='author' style='text-decoration: line-through'>#{comment.user.name}</span>"
    else
      content_tag :span,
        link_to(comment.user.name, user_path(comment.user)),
        :class => 'author'
    end
  end
  
  def activity_comment_target_link(comment, connector = "&rarr;")
    link = case comment.target_type
      when 'Conversation'
        link_to_conversation(comment.target.target)
      when 'Task'
        link_to_task(comment.target.target)
      when 'TaskList'
        link_to_task_list(comment.target.target)
    end
    "<span class='arr target_arr'>#{connector}</span> <span class='target'>#{link}</span>" if link
  end

  # TODO: phase out?
  def list_comments(comments, target)
    content_tag :div, render(comments), :class => 'comments', :id => 'comments'
  end
  
  def cancel_edit_comment_link(comment)
    link_to t('common.cancel'),
      project_comment_path(comment.project, comment),
      :class => 'edit_comment_cancel'
  end
  
  def cancel_convert_comment_link(comment)
    link_to t('common.cancel'),
      project_path(comment.project),
      :class => 'convert_comment_cancel'
  end
  
  def convert_comment_link(comment)
    link_to t('comments.actions.convert_task'),
      project_comment_path(comment.project, comment),
      :id => "convert_comment_#{comment.id}_link", 
      :class => 'commentConvert',
      :action_url => edit_project_comment_path(comment.project, comment, :part => 'task')
  end

  def edit_comment_link(comment)
    if comment.user_id == current_user.id
      link_to t('comments.actions.edit'),
        edit_project_comment_path(comment.project, comment),
        :id => "edit_comment_#{comment.id}_link", 
        :class => 'commentEdit taction',
        :action_url => edit_project_comment_path(comment.project, comment)
    end
  end
    
  def delete_comment_link(comment)
    link_to t('common.delete'),
      project_comment_path(comment.project, comment),
      :id => "delete_comment_#{comment.id}_link", 
      :class => 'commentDelete action',
      :aconfirm => t('.confirm_delete'),
      :action_url => project_comment_path(comment.project, comment)
  end

end