module PeopleHelper

  def person_header(project,person)
    render :partial => 'people/header', 
      :locals => { 
        :project => project,
        :person => person }
  end

  def person_link(project,person)
    if !person.owner? && project.admin?(current_user)
      action = person.new_record? ? 'new' : 'edit'

      link_to_function t("people.link.#{action}"), show_person(project,person),
        :class => "#{action}_person_link",
        :id => person_id("#{action}_link",project,person)
    end
  end

  def the_person_link(project,person)
    link_to "#{person.name}", user_path(person.user)
  end
  
  def person_id(element,project,person=nil)
    person ||= Person.new
    js_id(element,project,person)
  end
  
  def show_person(project,person)
    action = person.new_record? ? 'new' : 'edit'

    header_id = person_id("#{action}_header",project,person)
    form_id = person_id("#{action}_form",project,person)
    
    update_page do |page|
      page[header_id].hide
      page[form_id].show
      page << "Form.reset('#{form_id}')"
    end
  end

  def person_form(project,person)
    render :partial => 'people/form', :locals => {
      :project => project,
      :person => person }
  end

  def person_fields(f,project,person)
    render :partial => 'people/fields', :locals => {
      :f => f,
      :project => project,
      :person => person }
  end

  def people_form_for(project,person,&proc)
    raise ArgumentError, "Missing block" unless block_given?
    action = person.new_record? ? 'new' : 'edit'
      
    remote_form_for([project,person],
      :loading => person_form_loading(action,project,person),
      :html => {
        :id => person_id("#{action}_form",project,person), 
        :class => 'person_form', 
        :style => 'display: none;'}, 
        &proc)
  end

  def person_form_loading(action,project,person)
    update_page do |page|
      page[person_id("#{action}_submit",project,person)].hide
      page[person_id("#{action}_loading",project,person)].show
    end        
  end

   #can_transfer = (@current_user == person.project.user)
   #t('.transfer') if can_transfer != owner
  def remove_person_link(project,person,user)
    if project.owner?(user) && !person.owner?
      delete_person_link(project,person) 
    elsif person.user == user && !person.owner?
      leave_project_link(project,person)
    end  
  end  

  def list_people(project,people)
    render :partial => 'person', 
    :collection => people, 
    :as => :person, :locals => {
      :project => project }
  end
  
  def person_role(project,person)
    person.owner? ? t('.owner') : t(".#{person.role_name}")
  end
  
  def people_role_options
    Person::ROLES.map {|k,v| [ t("people.fields.#{k}"), v ] }.sort{|a,b| a[1] <=> b[1]}
  end
  
  def person_project_select_options(project)
    {:id => 'people_project_select', :people_url => project_contacts_path(project)}
  end
  
  def delete_person_link(project,person)
    link_to_remote t('.remove'), :url => project_person_path(project,person), :method => :delete,
      :confirm => t('.confirm_delete')
  end

  def leave_project_link(project,person)
    link_to t('.leave_project'), 
      project_person_path(project,person.id), 
      :method => :delete,
      :confirm => t('.confirm_delete')
  end
  
  def person_submit(project,person)
    action = person.new_record? ? 'new' : 'edit'
    submit_id = person_id("#{action}_submit",project,person)
    loading_id = person_id("#{action}_loading",project,person)
    submit_to_function t("people.#{action}.submit"), hide_person(project,person), submit_id, loading_id
  end
  
  def hide_person(project,person)
    action = person.new_record? ? 'new' : 'edit'

    header_id = person_id("#{action}_header",project,person)
    form_id = person_id("#{action}_form",project,person)

    update_page do |page|
      page[header_id].show
      page[form_id].hide
    end   
  end

end