module PagesHelper

  def page_primer(project)
    render 'pages/primer', :project => project if project.editable?(current_user)
  end

  def page_column(project,pages,current_target = nil)
    render 'pages/column',
      :project => project,
      :pages => pages,
      :current_target => current_target
  end
  
  def visible_pages_list(project)
    if current_user
      @pages = project.pages.where(['pages.is_private = ? OR (pages.is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                             joins("LEFT JOIN watchers ON (pages.id = watchers.watchable_id AND watchers.watchable_type = 'Page') AND watchers.user_id = #{current_user.id}")
    else
      @pages = project.pages.where(['pages.is_private = ?', false])
    end
  end
  
  def new_page_link(project)
    if can? :make_pages, project
      link_to content_tag(:span,t('.new_page')), new_project_page_path(project), :class => 'add_button'
    end
  end
  
  def page_fields(f)
    render 'pages/fields', :f => f
  end

  def list_pages_with_toc(pages)
    render pages
  end
  
  def edit_page_link(project,page)
    link_to t('common.edit'), edit_project_page_path(project,page)
  end
  
  def rename_page_link(project,page)
    link_to t('common.rename'), edit_project_page_path(project,page)
  end
  
  def edit_mobile_page_link(project,page)
    link_to t('common.edit'), edit_project_page_path(project,page, :edit_part => 'page')
  end

  def delete_page_link(project,page)
    link_to t('common.delete'), project_page_path(project,page),
      :method => :delete,
      :class => 'remove',
      :confirm => t('confirm.delete_page')
  end
  
  def page_action_links(project,page)
    if can? :update, page
      render 'pages/actions', :project => project, :page => page
    end
  end
  
  def page_slot_fields(slot = 0, before = 0)
    render 'pages/slot_fields', :pos_slot => slot, :pos_before => before
  end
  
  def drag_widget_handle(widget)
    image_tag('drag.png', :class => 'slot_handle')
  end
  
  def page_buttons(project,page)
    if can? :update, page
      render 'pages/buttons', :project => project, :page => page
    end
  end
  
  def insert_widget(widget_id, position, location, view_options={})
    page.call "Page.insertWidget", widget_id, position, location, render(view_options)
  end

  def slots_classes
    slots_classes = []
    slots_classes << 'readonly' unless can? :make_pages, @current_project
    slots_classes.join(" ")
  end
end
