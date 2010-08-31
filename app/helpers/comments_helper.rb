module CommentsHelper

  def cache_editable_comment(comment, threaded, simpleconv, &block)
    cache(comment.cache_key.tap { |key|
      key << "-#{comment.user.avatar_updated_at.to_i}-#{comment.project.permalink}"
      key << '-editable' if comment.can_edit?(current_user)
      key << '-destructable' if comment.can_destroy?(current_user)
      key << '-threaded' if threaded
      key << '-simpleconv' if simpleconv
      key << ".#{request.format.to_sym}" if request.format.to_sym.to_s =~ /^\w+$/
    }, &block)
  end
  
  def convert_comment_form_for(comment,&proc)
    form_for [comment.project,comment],
      :url => convert_project_comment_path(comment.project,comment),
      :html => {
        :id => js_id(:convert,comment.project,comment),
        :class => 'convert_comment'
      },
      &proc
  end
  
  def edit_comment_form_for(comment,&proc)
    form_for [comment.project,comment],
      :id => "comment_#{comment.id}_form",
      :method => :put,
      :html => {
        :class => 'edit_comment', 
        :update_id => js_id(nil,comment),
        :action_cancel => project_comment_path(comment.project,comment)},
      &proc
  end

  def non_js_comment_form_for(form_url,&proc)
    form_for form_url,
      :id => 'new_comment_form',
      &proc
  end

  def options_for_people(people, include_nobody = true)
    p = include_nobody ? [[t('.assigned_to_nobody'),nil]] : []
    people.sort_by{|a| a.name}.each {|person| p << [ person.name, person.id ]}
    p
  end
  
  def options_for_task_statuses
    t = []
    Task::STATUSES.to_enum(:each_with_index).each { |e,i| t << [e,i] unless i == 0 }
    t
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

  def new_comment_form(project,comment,options={})
    message = options[:message] ||= nil
    target  = options[:target]  ||= nil
    thread  = options[:thread]  ||= nil
    comment ||= Comment.new
    form_url = if project.nil?
                  [comment]
                elsif target.nil?
                  [project,comment]
                elsif target.is_a?(Task)
                  [project,target.task_list,target,comment]
                else
                  [project,target,comment]
                end

    if project.nil?
      commentable_projects = @projects.select { |p| p.commentable?(current_user) && !p.archived }
      can_comment = commentable_projects.any?
    else
      can_comment = project.commentable?(current_user) && !project.archived
    end

    if can_comment
      render 'comments/new',
        :target => target,
        :message => message,
        :form_url => form_url, 
        :comment => comment,
        :thread => thread,
        :commentable_projects => commentable_projects
    end
  end

  def select_project_for_comment(projects)
    select_tag :project_id, projects.map { |p|
      selected = "selected='selected'" if session[:last_project_commented] == p.permalink
      %(<option #{selected} value='#{p.permalink}'>#{p.name}</option>)
    }.join
  end

  def list_comments(comments,target)
    content_tag :div,
    render(:partial => 'comments/list_comments',
      :locals => {
        :comments => comments,
        :target => target }),
      :class => 'comments',
      :id => 'comments'
  end
  
  def comment_fields(f,comment,show_hours)
    render 'comments/fields', :f => f, :comment => comment, :show_hours => show_hours
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
  
  def last_comment_input
    hidden_field_tag 'last_comment_id', '0'
  end
  
  def comment_update_last_id
    javascript_tag <<-EOS
      var last = $$('#comments .comment:first');
      if (last.length > 0)
      {
        var val = $(last[0]).readAttribute('id').split('_')[1];
        $$('#last_comment_id').each(function(e){ e.writeAttribute('value', val); });
      }
    EOS
  end
  
  def comments_script(target)
    return unless target
    
    project = target.try(:project) || target
      
    update_page_tag do |page|
      page.assign('comments_update_url',get_comments_project_path(project))
      page.assign('comments_parameters', { :target_name => target.class.name, :target_id => target.id })
    end
  end

  def comment_text_area(f, target)
    placeholder = case target
    when Conversation then t('.conversation')
    when TaskList then t('.task_list')
    when Task then t('.task')
    else t('.project')
    end

    f.text_area :body, :class => 'comment_body', :id => 'comment_body', :placeholder => placeholder
  end

  def paint_status_boxes
    javascript_tag "Comment.paint_status_boxes()"
  end

end