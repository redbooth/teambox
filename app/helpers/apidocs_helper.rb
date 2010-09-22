module ApidocsHelper
  
  def doc_for(method, options={}, &block)
    @api_docs ||= ActiveSupport::OrderedHash.new
    @api_docs["#{@model}##{method}"] = options.merge(:description => capture(&block))
  end
  
  def ignore_doc_for(method)
    @api_docs ||= ActiveSupport::OrderedHash.new
    @api_docs["#{@model}##{method}"] = {:ignore => true}
  end
  
  def link_to_doc_model(model)
    link_to model.to_s.capitalize, model.to_s.downcase
  end

end