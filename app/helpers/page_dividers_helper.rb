module PageDividersHelper

  def divider_fields(f)
    render 'dividers/fields', :f => f
  end
  
  def new_page_divider_link(project,page)
    link_to content_tag(:span,t('.new_divider')), new_project_page_divider_path(project, page), :class => 'add_button divider_button'
  end
  
  def remove_form(show_element=nil)
    update_page do |page|  
      page << "$(this).up('form').remove();"
      if show_element
        page[show_element].show
      end
    end
  end

  def show_loading_divider_form(id=nil)
    update_page do |page|
      page.loading_divider_form(true,id)
    end  
  end
      
  def loading_divider_form(toggle,id=nil)
    if toggle
      page["divider_form_loading#{"_#{id}" if id}"].show
      page["divider_submit#{"_#{id}" if id}"].hide
    else
      page["divider_form_loading#{"_#{id}" if id}"].hide
      page["divider_submit#{"_#{id}" if id}"].show
    end
  end
  
end