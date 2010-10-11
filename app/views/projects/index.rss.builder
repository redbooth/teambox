rss_activity_feed :root_url => projects_url do |feed|
  for activity in @activities
    feed.entry activity if activity.target
  end
end
