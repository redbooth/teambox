class Page < ActiveRecord::Base
  include GrabName
  include Watchable

  belongs_to :user
  belongs_to :project
  has_many :notes, :order => 'position'
  has_many :dividers, :order => 'position'
    
  attr_accessible :name, :description, :note_attributes
  
  def build_note(note = {})
    self.notes.build(note) do |note|
      note.project_id = self.project_id
      note.page_id = self.id
    end
  end
  
  def build_divider(divider = {})
    self.dividers.build(divider) do |divider|
      divider.project_id = self.project_id
      divider.page_id = self.id
    end
  end  
  
  def new_note(note = {})
    self.notes.new(note) do |note|
      note.project_id = self.project_id
      note.page_id = self.id
    end
  end
  
  def after_create
    project.log_activity(self,'create')
  end
end