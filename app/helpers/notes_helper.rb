module NotesHelper

  def insert_new_note_form(project,current_page)  
    page.insert_html :after, "buttons",
      :partial => 'notes/new', 
      :locals => {          
        :project => project,
        :page => current_page,
        :note => Note.new,
        :unique_id => Time.current.to_i.to_s }
  end

  def note_fields(f)
    render :partial => 'notes/fields', :locals => { :f => f }
  end

  def list_page_notes(notes)
    render :partial => 'notes/note', :collection => notes
  end
  
  def add_note_link(project,page)
    link_to_remote "<span>#{t('.new_note')}</span>",
      :url => new_project_page_note_path(project,page),
      :method => :get,
      :html => { :class => 'button' }
  end
  
  def note_actions_link(note)
    render :partial => 'notes/actions',
      :locals => { :note => note }
  end
  
  def edit_note_link(note)
    link_to_remote pencil_image,
      :url => edit_project_page_note_path(note.project,note.page,note),
      :method => :get
  end
  
  def delete_note_link(note)
    link_to_remote trash_image,
      :url => project_page_note_path(note.project,note.page,note),
      :method => :delete,
      :confirm => t('.delete_confirm')
  end
end