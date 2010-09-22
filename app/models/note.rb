class Note < RoleRecord
  belongs_to :page
  belongs_to :project
  has_one :page_slot, :as => :rel_object
  acts_as_paranoid
  versioned
  
  include PageWidget
  
  before_destroy :clear_slot
  
  formats_attributes :body
  
  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
  
  def after_create
    save_slot
    project.log_activity(self, 'create', updated_by.id)
  end
  
  def after_update
    project.log_activity(self, 'edit', updated_by.id)
  end
  
  def slot_view
    'notes/note'
  end
  
  def to_s
    name
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.note :id => id do
      xml.tag! 'page-id',      page_id
      xml.tag! 'project-id',   project_id
      xml.tag! 'name',         name
      xml.tag! 'body',         body
      xml.tag! 'created-at',   created_at.to_s(:db)
      xml.tag! 'updated-at',   updated_at.to_s(:db)
    end
  end
  
  def to_api_hash(options = {})
    {
      :id => id,
      :project_id => project_id,
      :page_id => page_id,
      :slot_id => page_slot.id,
      :name => name,
      :body => body,
      :created_at => created_at.to_s(:db),
      :updated_at => updated_at.to_s(:db)
    }
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end
end