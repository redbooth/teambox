module JennyHelper
  #### AB - THIS MODULE WILL BE REFACTORED INTO A PLUGIN

  ## This generates id paths to be used for javascript.
  ##
  ##  eg. js_id(:edit_header,@project,@tasklist) => project_21_task_list_12_edit_header
  ##  eg. js_id(:new_header,@project,Task.new) => project_21_task_list_new_header
  ##  eg. js_id(@project,Task.new) => project_21_task_list
  def js_id(*args)
    if args.is_a?(Array)
      element = args[0].is_a?(String) || args[0].is_a?(Symbol) ? args[0] : nil
      models = args.slice(1,args.size-1)
      raise ArgumentError unless models.all?{|a|a.is_a?(ActiveRecord::Base)}
    elsif args.is_a?(ActiveRecord::Base)
      models = [args]
    else
      raise ArgumentError
    end
    generate_js_path(element,models)
  end

  def generate_js_path(element,models)
    path = []
    models.each do |model|
      path << model.class.to_s.underscore
      path << model.id unless model.new_record?
    end
    path << element unless element.nil?
    path.join('_')
  end
  
  def unobtrusive_app_link(*args)
    target, action = shes_just_a_memory(*args)
    return unless target.editable?(current_user)

    singular_name = target.class.to_s.underscore
    plural_name = target.class.to_s.tableize

    # TODO: check what uses show_*. Should be {action}_*
    link_to content_tag(:span,t("#{plural_name}.link.#{action}")), '#',
      {:class => "jennyaction #{action}_#{singular_name}_link",
      :id => js_id("#{action}_link",*args)}.merge(send("show_#{singular_name}".to_sym,*args))
  end
  
  def unobtrusive_app_toggle(*args)
    target, action = shes_just_a_memory(*args)

    header_id = js_id("#{action}_header",*args)
    link_id   = js_id("#{action}_link",*args)
    form_id   = js_id("#{action}_form",*args)

    {:new_record => target.new_record? ? 1 : 0,
     :header_id => header_id,
     :link_id => link_id,
     :form_id => form_id}
  end

  def unobtrusive_app_submit(*args)
    target, action = shes_just_a_memory(*args)

    plural_name = target.class.to_s.tableize

    submit_id = js_id("#{action}_submit",*args)
    loading_id = js_id("#{action}_loading",*args)
    submit_or_cancel target, t("#{plural_name}.#{action}.submit"), submit_id, loading_id
  end

  def unobtrusive_app_form_for(*args, &proc)
    raise ArgumentError, "Missing block" unless block_given?
    target, action = shes_just_a_memory(*args)

    header_id = js_id("#{action}_header",*args)
    link_id   = js_id("#{action}_link",*args)
    form_id   = js_id("#{action}_form",*args)
    
    singular_name = target.class.to_s.underscore
    form_for(args,
      :html => {
        :id => js_id("#{action}_form",*args),
        :class => "#{singular_name}_form jenny_form app_form",
        :jennybase => js_id("", *args),
        :jennytype => "#{action}_#{singular_name}",
        :style => 'display: none',
        # params for jenny to cancel
        :new_record => target.new_record? ? 1 : 0,
        :header_id => header_id,
        :link_id => link_id,
        :form_id => form_id},
        &proc)
  end

  def shes_just_a_memory(*args)
    # And she used to mean so much to me...
    target = args.last
    action = target.new_record? ? 'new' : 'edit'
    [target,action]
  end

  def show_form_errors(target,form_id)
    page.select("##{form_id} .error").each do |e|
      e.remove
    end
    target.errors.each do |field,message|
    errors = <<BLOCK
var e = $('#{form_id}').down('.#{field}');
if (e) {
if(e.down('.error'))
  e.down('.error').insert({bottom: "<br /><span>'#{message}'</span>"})
else
  e.insert({ bottom: "<p class='error'><span>#{message}</span></p>"})
}
BLOCK
      page << errors
    end
  end
  
  def remove_form_errors(target,form_id)
    page.select("##{form_id} .error").each do |e|
      e.remove
    end
  end

end