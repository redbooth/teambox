module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    when /the home\s?page/
      '/'
      
    when /the new project page/  
      "/projects/new"

    when /the account settings page/
      "/account/settings"

    when /the login page/
      "/login"

    when /the forgot password page/
      "/forgot"

    when /the project page/
      project_path(@current_project)
    when /the conversations page/
      project_conversations_path(@current_project)
    when /the task lists page/
      project_task_lists_path(@current_project)
    when /the people page/
      project_people_path(@current_project)
    when /the uploads page/        
      project_uploads_path(@current_project)
      
    #when /the index page for (.+)/
    #  polymorphic_path(model($1))
    
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
