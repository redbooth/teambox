Search = {
  // Determines if the AJAX request received should be displayed
  shouldDisplayResults: function(r) {
    return (r.request.url == Search.lastQuerySent) &&
           $('content').hasClassName('search_results');
  },
  getResults: function(query, force) {
    // Go back to the previous pane if the query string is empty
    if(query.length == 0) {
      Search.lastQueryTyped = null;
      Search.lastQuerySent = null;
      Pane.retrieve();
      return;
    }
    // Don't auto-search for short strings, unless we force search (pressing Return)
    if(query.length < 3 && !force) { return; }

    // Save the last query, and don't re-search if it's the same one we just fetched
    if (Search.lastQueryTyped == query) { return; }
    Search.lastQueryTyped = query;

    // Perform an API call to fetch search results
    var url = "/api/1/search/?q="+escape(query);
    new Ajax.Request(url, {
      method: "get",
      onLoading: function(r) {
        // Save content pane if we are going to show the search pane
        if(!Search.lastQuerySent) { Pane.save(); }
        // Mark this query as the last search we asked for
        Search.lastQuerySent = r.request.url;
        // Display a placeholder for search
        Pane.replace(
          Mustache.to_html(Templates.search.loading, { query: query }),
          "/search/?q="+escape(query)
        );
        $('content').addClassName('search_results');
      },
      onComplete: function(r) {
        if(!Search.shouldDisplayResults(r)) { return; }
        $('content').down('.loading').remove();
      },
      onSuccess: function(r) {
        if(!Search.shouldDisplayResults(r)) { return; }
        response = JSON.parse(r.responseText);
        Search.displayResults(response);
      },
      onFailure: function(r) {
        if(!Search.shouldDisplayResults(r)) { return; }
        $('search_result').update('<p>An error occurred, please try reloading the page.</p>');
      }
    })
  },
  displayResults: function(response) {
    response.objects.each(function(r) {
      r.icon_class = Search.icons[r.type];
      r.project = response.references.detect(function(p) {
        return p.type == "Project" && p.id == r.project_id;
      });
      r.link = "/projects/"+r.project.permalink+"/"+r.type.underscore()+"s/"+r.id;
      r.timeago = Date.timeAgo(r.updated_at);
    });
    response.length = response.objects.length;
    $('search_results').update(
      Mustache.to_html(Templates.search.results, response)
    );
  },
  icons: {
    "Conversation": 'comment_icon',
    "TaskList": 'task_icon',
    "Task": 'task_icon',
    "Page": 'page_icon'
  }
};

document.on('keydown', 'input#searchbox', function(e,el) {
  if (e.keyCode == Event.KEY_RETURN) {
    e.stop();
    Search.getResults($('searchbox').value, true);
  }
});

document.on('keydown', 'input#searchbox', function(e,el) {
  Search.getResults($('searchbox').value);
}.debounce(800)); // we only query once every 800 ms at most

// handles the "clear searchbox" event for webkit
document.on('click', 'input#searchbox', function(e,el) {
  Search.getResults($('searchbox').value);
});

document.on('click', 'a.closePane', function(e, el) {
  e.preventDefault();
  Pane.retrieve();
});

// [x] Hitting enter shouldn't take you to a new page
// [x] Should save the URL in the top bar
// [x] Should return back to content mode when closing search and turn back the URL
// [x] Relative times
// [x] Current search page should go ajax
// [x] Clean up translations, controller
// [ ] Pagination of results
// [x] Escape parameters in search/index from ruby
// [x] Text and translations for search
// [ ] Specs
// [ ] Cucumbers
