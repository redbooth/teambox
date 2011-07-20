module TeamboxDatasHelper
  def new_teambox_export_link
    link_to content_tag(:span,"Export"), new_teambox_data_path(:type => :export), :class => 'add_button'
  end
  
  def new_teambox_import_link
    link_to content_tag(:span,"Import"), new_teambox_data_path(:type => :import), :class => 'add_button'
  end
  
  def options_for_user_map
    [['Please Select...', '#invalid']] + current_user.users_for_user_map.map do |user|
      ["#{user.to_s} (@#{user.login})", user.login]
    end
  end
  
  def options_for_target_organization
    [['Please Select...', '#invalid']] + current_user.admin_organizations.map do |organization|
      ["#{organization}", organization.permalink]
    end
  end
  
  def fields_for_teambox_import(form, data)
    render :partial => 'teambox_datas/import_fields', :locals => {:f => form, :data => data}
  end
  
  def fields_for_teambox_export(form, data)
    render :partial => 'teambox_datas/export_fields', :locals => {:f => form, :data => data}
  end
  
  def map_table_for_data(teambox_data)
    render :partial => 'user_map',
           :collection => teambox_data.user_map.map{|key,value|[key,value]},
           :locals => {:users => teambox_data.users_lookup}
  end
end