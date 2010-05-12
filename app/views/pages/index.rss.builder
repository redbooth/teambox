rss_feed :root_url => project_pages_url(@current_project) do |feed|
  feed.title t('.rss.title', :name => @current_project.name)
  feed.description t('.rss.description', :name => @current_project.name)
  
  for page in @pages
    feed.entry page, :url => polymorphic_url([@current_project, page]) do |item|
      item.title page.name
      item.description page.description
      item.author page.user.name
    end
  end
end
