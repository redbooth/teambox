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
  
  def example_api_wrap(object, options={})
    api_controller = ApiV1::APIController.new
    api_controller.send 'api_wrap', object, options
  end
  
  def routes_for_model(modelname)
    mpath = modelname.underscore
    reject_actions = ['edit', 'new']
    [].tap do |list|
      @consolidated_routes.each do |route|
        next unless route[:controller].singularize == mpath
        next if reject_actions.include? route[:action]
        list << route
      end
    end.sort_by {|r| r[:action]}
  end
end