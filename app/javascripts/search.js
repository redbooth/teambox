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
          Mustache.to_html(Search.loading, { query: query }),
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
    });
    console.log(response);
    var html;
    html  = '<p>Got '+response.objects.length+' results</p>';
    html += Mustache.to_html(Search.template, response);
    $('search_results').update(html);
  },
  icons: {
    "Conversation": 'comment_icon',
    "TaskList": 'task_icon',
    "Task": 'task_icon',
    "Page": 'page_icon'
  },
  loading:
    "<h2>Results for <strong>{{query}}</strong></h2>"+
    "<div id='search_results'>"+
    "  <p class='loading'><img src='/images/loading.gif'/> Loading...</p>"+
    "</div>"+
    "<p><a class='closePane' href='#'>Close search</a></p>",
  template:
    "<div id='results'>"+
    "{{#objects}}"+
    "  <div class='result'>"+
    "    <div class='{{icon_class}}'></div>"+
    "    {{#project}}"+
    "      <a href='/projects/{{permalink}}'>{{name}}</a>"+
    "    {{/project}} &rarr;"+
    "    <a href='{{link}}'>{{name}}</a>"+
    "    <span class='time'>many days ago!!</span>"+
    "  </div>"+
    "{{/objects}}"+
    "</div>"
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
// [ ] Relative times
// [x] Current search page should go ajax
// [ ] Clean up search.sass, search/index, search/result, translations, controller
// [ ] Pagination of results
// [x] Escape parameters in search/index from ruby
