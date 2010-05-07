class PageSlot < ActiveRecord::Base
  belongs_to :page
  belongs_to :rel_object, :polymorphic => true
  
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
end
