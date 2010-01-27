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
      root_path
    when /the new project page/
      new_project_path
    when /the account settings page/
      account_settings_path
    when /the login page/
      login_path
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
    when /its task list page/
      project_task_list_path(@current_project,@task_list)
    when /its task page/
      project_task_list_task_path(@current_project,@task_list,@task)
    when /project settings path/
      project_settings_path(@current_project)
    when /the list of tasks page of the project called "(.+)"/
      project = Project.find_by_name($1)
      project_task_lists_path(project)
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
