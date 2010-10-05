class Page < RoleRecord
  has_many :notes
  has_many :dividers
  has_many :uploads
  
  has_many :slots, :class_name => 'PageSlot', :order => 'position ASC'

  has_permalink :name, :scope => :project_id

  attr_accessible :name, :description, :note_attributes
  attr_accessor :suppress_activity

  validates_length_of :name, :minimum => 1
  
  default_scope :order => 'position ASC, created_at DESC, id DESC'
  
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
       insert_pos = nil
       
       # Assuming we have an insert_id...
       if !insert_id.nil? and insert_id != 0
         old_slot = PageSlot.find(insert_id) rescue nil
         insert_pos = (insert_before ? old_slot.position : old_slot.position+1) unless old_slot.nil?
       end
       
       # Fallback
       if insert_pos.nil?
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
  
  def after_update
    project.log_activity(self, 'edit') unless @suppress_activity
  end
  
  def to_s
    name
  end

  def to_param
    permalink || id.to_s
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
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :project_id => project_id,
      :user_id => user_id,
      :name => name,
      :description => description,
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :watchers => Array.wrap(watchers_ids)
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :slots
      base[:slots] = slots.map{|s| s.to_api_hash(options)}
    end
    
    base
  end
end