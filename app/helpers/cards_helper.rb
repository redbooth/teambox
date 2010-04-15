module CardsHelper

  def options_for_card_type(types)
    types.to_enum(:each_with_index).collect{|type,i|[type,i]}
  end

  def render_card(card)
    render :partial => 'cards/card', :locals => { :card => card }
  end

  def remove_link_unless_new_record(fields)
    out = ''
    out << fields.hidden_field(:_delete)  unless fields.object.new_record?
    out << link_to(trash_image, "##{fields.object.class.name.underscore}", :class => 'remove_nested_item')
    out
  end

  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= "cards/#{method.to_s.singularize}"
    options[:form_builder_local] ||= :f  

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end
  
  def card_field(f,field)
    render :partial => "cards/#{field.singularize}", :locals => { :f => f, :field => field }
  end
  
  def render_card_field(f,field)
    render :partial => 'cards/field', :locals => { :f => f, :field => field }
  end

  def list_card_fields(f,fields)
    render :partial => 'cards/fields', :locals => { :f => f, :fields => fields }
  end
  
  def add_crm_link(field)
    link_to "+ #{t(".add_#{field}")}", "##{field}", :class => "add_nested_item add_crm_link", :rel => "#{field}"
  end
  
end  