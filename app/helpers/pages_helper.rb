module PagesHelper

  def page_primer(project)
    render :partial => 'pages/primer', :locals => { :project => project }
  end

  def page_column(project,pages,current_target = nil)
    render :partial => 'pages/column', :locals => {
      :project => project,
      :pages => pages,
      :current_target => current_target }
  end
  
  def new_page_link(project)
    return unless project.editable?(current_user)
    link_to content_tag(:span,t('.new_page')), new_project_page_path(project), :class => 'add_button'
  end
  
  def page_fields(f)
    render :partial => 'pages/fields', :locals => { :f => f }
  end
  
  def list_pages(pages,current_target)
    render :partial => 'pages/page', :collection => pages, :locals => {
      :current_target => current_target }
  end

  def page_link(page)
    link_to h(page.name), project_page_path(page.project,page)
  end
  
  def edit_page_link(project,page)
    link_to t('common.edit'), edit_project_page_path(project,page)
  end

  def delete_page_link(project,page)
    link_to t('common.delete'), edit_project_page_path(project,page), :method => :delete
  end
  
  def notes_sortable_tag(page)
    url = project_page_path(page.project,page)
    update_page_tag do |page|
      page.notes_sortable(url)
    end
  end
  
  def notes_sortable(url)
    page.sortable('notes', {
      :tag => 'div',
      :handle => 'img.drag',
      :url => url,
      :method => :put
    })
  end
  
  def page_action_links(project,page)
    return unless project.editable?(current_user)
    render :partial => 'pages/actions',
    :locals => { 
      :project => project,
      :page => page }
  end
  
  def page_buttons(project,page)
    return unless project.editable?(current_user)
    render :partial => 'pages/buttons', :locals => {}
  end
  
end