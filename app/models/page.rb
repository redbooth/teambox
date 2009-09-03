class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  has_many :notes, :order => 'position'
  
  attr_accessible :name, :note_attributes
  
  def build_note(note = {})
    self.notes.build(note) do |note|
      note.project_id = self.project_id
      note.page_id = self.id
    end
  end
  
  def new_note(note = {})
    self.notes.new(note) do |note|
      note.project_id = self.project_id
      note.page_id = self.id
    end
  end
end