rss_activity_feed :project => @current_project, :root_url => project_url(@current_project) do |feed|
  for activity in @activities
    feed.entry activity
  end
end
