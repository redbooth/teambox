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

    when /my settings page/
      "/settings"

    when /the login page/
      "/login"

    when /the forgot password page/
      "/forgot"

    when /the conversations page/
      "/projects/ruby_rockstars/conversations"

    when /the task lists page/
      "/projects/ruby_rockstars/task_lists"

    when /the people page/
      "/projects/ruby_rockstars/people"
      
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
