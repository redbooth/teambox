module PageTaskListHelper

  def new_page_task_list_link(project,page)
    link_to_remote "<span>#{t('.new_task_list')}</span>".html_safe,
      :url => new_project_page_task_list_path(project,page),
      :method => :get,
      :html => { :class => 'add_button' }
  end

end