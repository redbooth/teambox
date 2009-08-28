module PagesHelper
  def new_page_link(project)
    link_to 'New Page', new_project_page_path(project)
  end
  
  def page_fields(f)
    render :partial => 'pages/fields', :locals => { :f => f }
  end
  
  def name_actions(page)
    render :partial => 'pages/name_actions', :locals => { :page => page }
  end
  
  def rename_link(page)
    link_to_remote 'Rename',
      :method => :get,
      :url => rename_project_page_path(@current_project,page),
      :loading => show_loading('rename'),
      :complete => hide_loading('rename'),
      :html =>{ :id => "rename_link" }
  end
  
  def page_name(page)
    render :partial => 'pages/name', :locals => { :page => page }
  end
  
  def section_divider_actions(page,id)
    render :partial => 'pages/section_divider_actions', :locals => { :page => page, :id => id }
  end
  
  def section_divider(page)
    id = rand(999999999)
    render :partial => 'pages/section_divider', :locals => { :page => page, :id => id }
  end
  
  def insert_section_link(page,id)
    link_to_remote 'Insert',
      :method => :get,
      :url => section_divider_project_page_path(@current_project,page) + "?pid=#{id}",
      :loading => show_loading("section",id),
      :complete => hide_loading("section",id),
      :html => {:id => "section_#{id}_link"}
  end
  
  def insert_divider_link(page,id)
    link_to_remote 'Divider',
      :method => :get,
      :url => new_project_page_divider_path(@current_project,page) + "?pid=#{id}",
      :loading => show_loading("divider",id),
      :update => "section_divider_active_#{id}",
      :html => { :id => "divider_#{id}_link" }
  end
end