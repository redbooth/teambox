class PageSlot < ActiveRecord::Base
  belongs_to :page
  belongs_to :rel_object, :polymorphic => true
  
  named_scope :with_widgets, :include => [:rel_object]
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.slot :id => id do
      xml.tag! 'rel-object-id',      rel_object_id
      xml.tag! 'rel-object-type',    rel_object_type
      xml.tag! 'position',           position
      if Array(options[:include]).include? :rel_object
        rel_object.to_xml(options.merge({ :skip_instruct => true }))
      end
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :rel_object_id => rel_object_id,
      :rel_object_type => rel_object_type,
      :position => position
    }
    
    if Array(options[:include]).include? :rel_object
      base[:rel_object] = rel_object.to_api_hash(options)
    end
    
    base
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end
end
