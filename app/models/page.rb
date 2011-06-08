class Page < RoleRecord
  include Immortal
  include Watchable

  has_many :notes, :dependent => :destroy
  has_many :dividers, :dependent => :destroy
  has_many :uploads, :dependent => :destroy
  
  has_many :slots, :class_name => 'PageSlot', :order => 'position ASC', :dependent => :delete_all
  
  has_permalink :name, :scope => :project_id
  
  attr_accessible :name, :description, :note_attributes, :is_private, :private_ids
  attr_accessor :suppress_activity
  attr_accessor :updating_user
  attr_accessor :private_ids
  
  validates_presence_of :user
  validates_length_of :name, :minimum => 1
  validate :check_updating_user, :on => :update
  
  default_scope :order => 'position ASC, created_at DESC, id DESC'
  
  after_create :log_create, :update_user_stats, :set_private_ids
  after_update :log_update, :set_private_ids
  
  def check_updating_user
    return if @updating_user.nil?
    @errors.add :is_private, 'cannot be set' if @is_private_set && (@updating_user != user)
    @errors.add :private_ids, 'cannot be updated' if is_private && (@updating_user != user)
  end
  
  def is_private=(value)
    self[:is_private] = value
    @is_private_set = true
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
  
  def log_create
    project.log_activity(self,'create')
  end
  
  def log_update
    project.log_activity(self, 'edit') unless @suppress_activity
  end
  
  def set_private_ids
    if is_private && @private_ids && @is_private_set
      set_private_watchers(@private_ids)
    end
  end

  def references
    refs = { :users => [user_id], :projects => [project_id] }
    refs[:note] = note_ids
    refs[:divider] = divider_ids
    refs[:upload] = upload_ids
    refs
  end
  
  def to_s
    name
  end

  def to_param
    permalink || id.to_s
  end
  
  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
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
  
  def update_user_stats
    user.increment_stat 'pages' if user
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
      :watchers => Array.wrap(watcher_ids),
      :is_private => is_private
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    
    if Array(options[:include]).include? :slots
      base[:slots] = slots.map{|s| s.to_api_hash(options)}
    end
    
    if Array(options[:include]).include? :objects
      base[:objects] = refs_objects.map{|o| o.to_api_hash(:emit_type => true)}
    end
    
    base
  end

  define_index do
    set_property :group_concat_max_len => 1024 * 10
    where Page.undeleted_clause_sql

    indexes name, :sortable => true
    indexes description
    indexes notes.name, :as => :note_name
    indexes notes.body, :as => :note_body
    indexes dividers.name, :as => :divider_name
    indexes uploads(:asset_file_name), :as => :upload_name
    has project_id, created_at, updated_at
  end
end
