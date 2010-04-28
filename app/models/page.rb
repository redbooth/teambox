class Page < RoleRecord
  has_many :notes
  has_many :dividers
  has_many :uploads
  
  has_many :slots, :class_name => 'PageSlot', :order => 'position ASC'
  
  attr_accessible :name, :description, :note_attributes

  validates_length_of :name, :minimum => 1
  
  def self.widgets
     [Note, Divider]
  end
  
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
  
  def new_slot(insert_id, insert_before, widget)
     PageSlot.transaction do
       # Calculate correct position
       if !insert_id.nil? and insert_id != 0
         old_slot = PageSlot.find(insert_id)
         insert_pos = insert_before ? old_slot.position : old_slot.position+1
       else
         if self.slots.empty?
           insert_pos = 0
         else
           insert_pos = insert_before ? self.slots[0].position : 
                                        self.slots[self.slots.length-1].position+1
         end
       end
       
       # Bump up all other slots
       self.slots.each do |slot|
         if slot.position >= insert_pos
           slot.position += 1
           slot.save
         end
       end
       
       # Make the new slot, damnit!
       slot = PageSlot.new(:page => self, :position => insert_pos, :rel_object => widget)
       slot.save
       
       slot
     end      
  end
  
  def divided_slots
    groups = []
    divider = nil
    items = []
    slots.each do |slot|
      if slot.rel_object_type == 'Divider'
        if divider or items.length > 0
          groups << [divider, items]
          items = []
        end
        divider = slot
      else
        items << slot
      end
    end
    
    # Final group
    if divider or items.length > 0
      groups << [divider, items]
    end
    
    groups
  end
  
  def after_create
    project.log_activity(self,'create')
  end
  
  def to_s
    name
  end
  
  def user
    User.find_with_deleted(user_id)
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.page :id => id do
      xml.tag! 'project-id',      project_id
      xml.tag! 'user-id',         user_id
      xml.tag! 'name',            name
      xml.tag! 'description',     description
      xml.tag! 'created-at',      created_at.to_s(:db)
      xml.tag! 'updated-at',      updated_at.to_s(:db)
      xml.tag! 'watchers',        Array(watchers_ids).join(',')
      if Array(options[:include]).include? :slots
        slots.to_xml(options.merge({ :skip_instruct => true, :root => 'slots' }))
      end
      if Array(options[:include]).include? :objects
        notes.to_xml(options.merge({ :skip_instruct => true, :root => 'notes' }))
        dividers.to_xml(options.merge({ :skip_instruct => true, :root => 'dividers' }))
        uploads.to_xml(options.merge({ :skip_instruct => true, :root => 'uploads' }))
      end
    end
  end
end