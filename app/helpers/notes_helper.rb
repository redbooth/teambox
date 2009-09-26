module NotesHelper
  def list_page_notes(notes)
    render :partial => 'notes/note', :collection => notes
  end
  
  def add_note_link(project,page)
    link_to_remote "<span>#{t('.new_note')}</span>",
      :url => project_page_notes_path(project,page),
      :method => :post,
      :html => { :class => 'button' }
  end
  
  def note_actions(note)
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