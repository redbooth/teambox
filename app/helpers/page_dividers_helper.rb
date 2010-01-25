module PageDividersHelper

  def new_divider_form(project,page)
    render :partial => 'dividers/new', :locals => { 
      :project => project, :page => page, :divider => Divider.new } 
  end

  def inline_hide_divider_form
    update_page do |page|
      page.hide_divider_form
    end  
  end  

  def hide_divider_form
    page["new_divider_form"].hide
    page << "Form.reset('new_divider_form');"
  end

  def show_divider_form(in_bar)
    update_page do |page|
      unless in_bar
        page.call "InsertionMarker.set", nil, true
        page.call "InsertionBar.place"
      end
      page.call "InsertionBar.setWidgetForm", "new_divider_form"
      #page << "new Effect.Highlight('new_divider_form',{ startcolor: '#F0F0F0', endcolor: '#F5F5F5', restorecolor: '#FFFFFF'})"
      page << "Form.reset('new_divider_form');"
      page.hide_loading_divider_form
      page << "$('new_divider_form').auto_focus()"
    end  
  end

  def divider_fields(f)
    render :partial => 'dividers/fields', :locals => { :f => f }
  end

  def list_page_dividers(dividers)
    render :partial => 'dividers/divider', :collection => dividers
  end
  
  def new_page_divider_link(project,page,in_bar)
    link_to_function content_tag(:span,t('.new_divider')), show_divider_form(in_bar), :class => 'add_button', :id => 'divider_button'
  end
  
  def new_loading_form
    update_page do |page|
      page['divider_button'].className = 'loading_button'
    end  
  end
  
  def divider_actions_link(divider)
    return unless divider.editable?(current_user)
    render :partial => 'dividers/actions',
      :locals => { :divider => divider }
  end
  
  def edit_divider_link(divider)
    link_to_remote pencil_image,
      :url => edit_project_page_divider_path(divider.project,divider.page,divider),
      :loading => edit_divider_loading_action(divider),
      :method => :get, 
      :html => { :id => "edit_divider_#{divider.id}_link"}
  end

  
  def edit_divider_loading_action(divider)
    update_page do |page|
      page.insert_html :after, "edit_divider_#{divider.id}_link", loading_action_image("divider_#{divider.id}")
      page["edit_divider_#{divider.id}_link"].hide
    end  
  end
  
  def delete_divider_loading_action(divider)
    update_page do |page|
      page.insert_html :after, "delete_divider_#{divider.id}_link", loading_action_image("divider_#{divider.id}")
      page["delete_divider_#{divider.id}_link"].hide
    end  
  end  
  
  def delete_divider_link(divider)
    link_to_remote trash_image,
      :url => project_page_divider_path(divider.project,divider.page,divider),
      :loading => delete_divider_loading_action(divider),
      :method => :delete,
      :confirm => t('.delete_confirm'),
      :html => { :id => "delete_divider_#{divider.id}_link" }
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
    
  def hide_loading_divider_form(id=nil)
    page.loading_divider_form(false,id)
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