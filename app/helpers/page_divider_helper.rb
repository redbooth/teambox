module PageDividerHelper
  
  def new_page_divider_link(project,page)
    link_to_remote "<span>#{t('.new_divider')}</span>",
      :url => new_project_page_divider_path(project,page),
      :method => :get,
      :html => { :class => 'button' }
  end
    
end  