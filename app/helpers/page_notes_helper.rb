module PageNotesHelper

  def new_note_form(project,page)
    render :partial => 'notes/new', :locals => { 
      :project => project, :page => page, :note => Note.new } 
  end

  def inline_hide_note_form
    update_page do |page|
      page.hide_note_form
    end  
  end  

  def hide_note_form
    page["new_note_form"].hide
    page << "Form.reset('new_note_form');"
  end

  def show_note_form(in_bar)
    update_page do |page|
      unless in_bar
        page.call "InsertionMarker.set", nil, true
        page.call "InsertionBar.place"
      end
      page.call "InsertionBar.setWidgetForm", "new_note_form"
      page << "new Effect.Highlight('new_note_form',{ startcolor: '#F0F0F0', endcolor: '#F5F5F5', restorecolor: '#F5F5F5'})"
      page << "Form.reset('new_note_form');"
      page.hide_loading_note_form
      page << "$('new_note_form').auto_focus()"
    end  
  end

  def note_fields(f)
    render :partial => 'notes/fields', :locals => { :f => f }
  end

  def list_page_notes(notes)
    render :partial => 'notes/note', :collection => notes
  end
  
  def new_page_note_link(project,page,in_bar)
    link_to_function "<span>#{t('.new_note')}</span>", show_note_form(in_bar), :class => 'add_button', :id => 'note_button'
  end
  
  def new_loading_form
    update_page do |page|
      page['note_button'].className = 'loading_button'
    end  
  end
  
  def note_actions_link(note)
    return unless note.editable?(current_user)
    render :partial => 'notes/actions',
      :locals => { :note => note }
  end
  
  def edit_note_link(note)
    link_to_remote t('common.edit'),
      :url => edit_project_page_note_path(note.project,note.page,note),
      :loading => edit_note_loading_action(note),
      :method => :get, 
      :html => { :id => "edit_note_#{note.id}_link"}
  end

  
  def edit_note_loading_action(note)
    update_page do |page|
      page.insert_html :after, "edit_note_#{note.id}_link", loading_action_image("note_#{note.id}")
      page["edit_note_#{note.id}_link"].hide
    end  
  end
  
  def delete_note_loading_action(note)
    update_page do |page|
      page.insert_html :after, "delete_note_#{note.id}_link", loading_action_image("note_#{note.id}")
      page["delete_note_#{note.id}_link"].hide
    end  
  end  
  
  def delete_note_link(note)
    link_to_remote t('common.delete'),
      :url => project_page_note_path(note.project,note.page,note),
      :loading => delete_note_loading_action(note),
      :method => :delete,
      :confirm => t('.delete_confirm'),
      :html => { :class => 'delete', :id => "delete_note_#{note.id}_link" }
  end
  
  def remove_form(show_element=nil)
    update_page do |page|  
      page << "$(this).up('form').remove();"
      if show_element
        page[show_element].show
      end
    end
  end

  def show_loading_note_form(id=nil)
    update_page do |page|
      page.loading_note_form(true,id)
    end  
  end  
    
  def hide_loading_note_form(id=nil)
    page.loading_note_form(false,id)
  end
      
  def loading_note_form(toggle,id=nil)
    if toggle
      page["note_form_loading#{"_#{id}" if id}"].show
      page["note_submit#{"_#{id}" if id}"].hide
    else
      page["note_form_loading#{"_#{id}" if id}"].hide
      page["note_submit#{"_#{id}" if id}"].show
    end
  end
end