class Divider < RoleRecord
  belongs_to :page
  belongs_to :project
  has_one :page_slot, :as => :rel_object
  acts_as_paranoid
  versioned
  
  before_destroy :clear_slot

  attr_accessor :deleted
  attr_accessible :body, :deleted, :name
  
  def after_create
    project.log_activity(self, 'create', updated_by.id)
  end
  
  def after_update
    project.log_activity(self, 'edit', updated_by.id)
  end
  
  def clear_slot
    page_slot.destroy
  end

  def slot_view
    'dividers/divider'
  end
  
  def to_s
    name
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.divider :id => id do
      xml.tag! 'page-id',      page_id
      xml.tag! 'project-id',   project_id
      xml.tag! 'name',         name
      xml.tag! 'created-at',   created_at.to_s(:db)
      xml.tag! 'updated-at',   updated_at.to_s(:db)
    end
  end
end