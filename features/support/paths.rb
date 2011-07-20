module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
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
    when /the your data page/
      teambox_datas_path
    when /the pages of the "([^\"]*)" project/
      project_pages_path(Project.find_by_name($1))
    when /the page named "([^\"]*)"/
        project_page_path(@current_project, Page.find_by_name($1))
    when /the project page/
      project_path(@current_project)
    when /the public project page/
      public_project_path(@current_project)
    when /the page of the "([^\"]*)" project/
      project_path(Project.find_by_name($1))
    when /the conversations page/
      project_conversations_path(@current_project)
    when /the new conversation page/
      new_project_conversation_path(@current_project)
    when /the task lists page$/
      project_task_lists_path(@current_project)
    when /the page of the "([^\"]*)" conversation/
      conv = Conversation.find_by_name($1)
      project_conversation_path(conv.project, conv)
    when /the uploads page$/
      project_uploads_path(@current_project)
    when /the people page of the "([^\"]*)" project$/
      project_people_path(Project.find_by_name($1))
    when /the uploads page of the "([^\"]*)" project$/
      project = Project.find_by_name($1)
      project_uploads_path(project)
    when /its task list page/
      project_task_list_path(@current_project,@task_list)
    when /its task page/
      project_task_path(@current_project,@task)
    when /project settings page/
      project_settings_path(@current_project)
    when /the "(.+)" tasks page/
      project = Project.find_by_name($1)
      project_task_lists_path(project)
    when /the "([^\"]*)" task list page of the "([^\"]*)" project/
      task_list = TaskList.find_by_name($1)
      project = Project.find_by_name($2)
      project_task_list_path(project, task_list)
    when /the page of the "([^\"]*)" task/
      task = Task.find_by_name($1)
      project_task_path(task.project, task)
    when /the profile of "([^\"]*)"/
      user = User.find_by_login($1)
      user_path(user)
    when /my settings page/
      account_settings_path
    when /the signup page/
      signup_path
    when /the public projects page/
      public_projects_path
    when /the organizations page/
      organizations_path
    when /the admin users page for the for "([^\"]*)" organization/
      organization_memberships_path(Organization.find_by_name($1))
    when /the new organization page/
      new_organization_path
    when /the participant page for the "([^\"]*)" organization/
      organization = Organization.find_by_name($1)
      organization_path(organization)
    when /the public site for "([^\"]*)" organization/
      organization = Organization.find_by_name($1)
      site_path(organization)
    when /the appearance page for the "([^\"]*)" organization/
      organization = Organization.find_by_name($1)
      appearance_organization_path(organization)
    when /the apidocs page/
      '/api'
    when /time tracking/
      time_path
    when /the results page for "(.+)"/
      search_path :q => $1
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
