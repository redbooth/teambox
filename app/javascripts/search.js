Search = {
  // Determines if the AJAX request received should be displayed
  shouldDisplayResults: function(r) {
    return (r.request.url == Search.lastQuerySent) &&
           $('content').hasClassName('search_results');
  },
  getResults: function(query, force, page) {
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
    var url = "/api/1/search/?q="+escape(query) + (page ? '&page=' + page : '');
    Search.fetch(url, query, page);
  },
  fetch: function(url, query, page) {
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
          "/search/?q="+escape(query) + (page ? '&page=' + page : '')
        );
        $('content').addClassName('search_results');
        $('content').down('.pagination_links').hide();
      },
      onComplete: function(r) {
        if(!Search.shouldDisplayResults(r)) { return; }
        $('content').down('.loading').remove();
      },
      onSuccess: function(r) {
        if(!Search.shouldDisplayResults(r)) { return; }
        response = JSON.parse(r.responseText);
        Search.displayResults(response, query);
        if (response.total_pages > 1) {
          $('content').down('.pagination_links').show();
        }
      },
      onFailure: function(r) {
        if(!Search.shouldDisplayResults(r)) { return; }
        $('search_result').update('<p>An error occurred, please try reloading the page.</p>');
      }
    });
  },
  displayResults: function(response, query) {
    response.objects.each(function(r) {
      r.icon_class = Search.icons[r.type];
      r.project = response.references.detect(function(p) {
        return p.type == "Project" && p.id == r.project_id;
      });
      r.link = "/projects/"+r.project.permalink+"/"+r.type.underscore()+"s/"+r.id;
      r.timeago = Date.parseFormattedString(r.updated_at).timeAgo();
      r.name = (r.name || r.first_comment.body_html.stripTags()).truncate(65);
    });
    response.length = response.total_entries;

    /*
    * Create list of pagination links
    */
    function pagination() {
      var links = new Array(response.total_pages);

      /*
      * Calculate page ranges
      */
      function entry_info(page, per_page, total_entries, total_pages) {
        var offset = page > 1 ? ((page - 1)* per_page + (page - 1)) : 1
        , diff = ((page * per_page) - total_entries)
        , length = diff > 0 ? total_entries : (offset + per_page);

        var info = "#{start}-#{finish}".interpolate({start: offset, finish: page > 1 ? length : (length - 1)});

        if (response.total_pages < 2) {
          if (reponse.length.length < 2) { return ""; }
          else {
            return info;
          }
        }
        else {
          return info;
        }
      };

      for (var i = 0; i < response.total_pages; i++) {
        var url = "/api/1/search/?q="+escape(query) + '&page=' + (i + 1)
        , entry = new Element('li', {})
        , info = entry_info(i + 1
                            , response.per_page
                            , response.total_entries
                            , response.total_pages
                           );

        if (response.current_page !== (i + 1)) {
          entry.insert({bottom: new Element('a', {
                                 href: url
                                 , className: 'page'
                                 , "data-attribute-query": query
                                 , "data-attribute-page": (i+1)
                                })
               .update(info)});
        }
        else {
          entry.insert({bottom: new Element('span').update(info)});
        }

        links.push(entry);
      };
      return links;
    };

    var results = $('search_results').update(
      Mustache.to_html(Templates.search.results, response)
    );
    var pages = pagination();
    pages.each(function(li) {
      results.next('.pagination_links').down('.pages').insert({bottom: li});
    });
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

document.on('click', '.search_results a.page', function(e,el) {
  e.stop();
  var url = el.getAttribute('href')
  , query = el.getAttribute('data-attribute-query')
  , page = el.getAttribute('data-attribute-page');

  Search.fetch(url, query, page);
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
