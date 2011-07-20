module CardsHelper

  def options_for_card_type(types)
    types.to_enum(:each_with_index).collect do |type,i|
       [t("cards.card_types.#{type.downcase}", :default => type),i]
    end
  end

  def render_card(card)
    render 'cards/card', :card => card if card
  end

  def remove_link_unless_new_record(fields)
    ''.tap do |out|
      out << fields.hidden_field(:_destroy) unless fields.object.new_record?
      out << link_to("", "##{fields.object.class.name.underscore}", :class => 'remove_nested_item trash_icon')
    end.html_safe
  end

  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= "cards/#{method.to_s.singularize}"
    options[:form_builder_local] ||= :f  

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render options[:partial], options[:form_builder_local] => f
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end
  
  def card_field(f,field)
    render "cards/#{field.singularize}", :f => f, :field => field
  end
  
  def render_card_field(f,field)
    render 'cards/field', :f => f, :field => field
  end

  def list_card_fields(f,fields)
    render 'cards/fields', :f => f, :fields => fields
  end
  
  def add_crm_link(field)
    link_to "+ #{t(".add_#{field}")}", "##{field}", :class => "add_nested_item add_crm_link", :rel => "#{field}"
  end
  
end  
