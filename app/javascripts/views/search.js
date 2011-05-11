// Displays quick search results when typing on the top bar

Teambox.Views.Search = Backbone.View.extend({

  events: {
    "keydown input#searchbox":  "navigateQuickResults",
    "keyup input#searchbox":    "showQuickResults",
    "focusout input#searchbox": "hideQuickResults"
  },

  quickresult_template: Handlebars.compile(Templates.search.quicksearch),
  loading_template: Handlebars.compile(Templates.search.loading),
  results_template: Handlebars.compile(Templates.search.results),

  initialize: function(options) {
    this.app = options.app;
  },

  // Keyboard navigation for quick results
  navigateQuickResults: function(evt) {
    // When pressing Enter..
    if (evt.keyCode === Event.KEY_RETURN) {
      // Run full search, and prevent submitting the form
      if (this.highlight_index === 0) {
        this.submitSearch();
      } else { // or navigate to the selected element
        var a = $('quicksearch_results').down('li.selected a');
        document.location = a.readAttribute('href');
      }
      evt.stop();
      return;
    }

    // Close the search box when clicking Esc
    if (evt.keyCode === Event.KEY_ESC) {
      this.hideQuickResults();
      $('searchbox').blur();
      evt.stop();
      return;
    }

    // Prevent up/down cursor actions on the input
    if (evt.keyCode === Event.KEY_UP) { evt.stop(); return; }
    if (evt.keyCode === Event.KEY_DOWN) { evt.stop(); return; }
  },

  // Display the 20 most recent matching results
  showQuickResults: function(evt) {
    // Ignore Enter and Esc, since they are already handled on keydown
    if (evt.keyCode === Event.KEY_RETURN) { evt.stop(); return; }
    if (evt.keyCode === Event.KEY_ESC) { evt.stop(); return; }

    // Move highlighted element up or down, if possible
    if (evt.keyCode === Event.KEY_UP) { this.moveHighlight(-1); evt.stop(); return; }
    if (evt.keyCode === Event.KEY_DOWN) { this.moveHighlight(1); evt.stop(); return; }

    var search_term = $('searchbox').value;

    // If text search is empty, hide the results box
    if(search_term.length === 0) {
      this.hideQuickResults();
    }

    // Find matches among the titles of my elements
    var regex = RegExp('\\W'+search_term, 'i');
    var found = this.app.my_tasks.models.select(function(i) {
      return i.get('name') &&
        (" "+i.get('name').toLowerCase()).match(regex);
    }).sortBy(function(i) {
      return i.updated_at;
    }).slice(0,20).collect(function(i) { return i.toJSON(); });

    // Display the dropdown menu with results
    $$('#quicksearch_results').invoke('remove');
    $(document.body).insert({ top:
      this.quickresult_template({ results: found, query: escape(search_term) })
    });
    this.highlight_index = 0;

    // Highlight matches in results
    $$('#quicksearch_results li a').each(function(a) {
      var regex = new RegExp(search_term, 'ig');
      a.innerHTML = a.innerHTML.replace(regex, "<b>$&</b>");
    });
  },

  // Move the highlighted index in quick results up and down
  moveHighlight: function(inc) {
    if (!$('quicksearch_results')) { return; }
    this.highlight_index = (this.highlight_index + inc) || 0;
    var lis = $('quicksearch_results').select('li');
    this.highlight_index = [0, this.highlight_index].max();
    this.highlight_index = [lis.length-1, this.highlight_index].min();
    lis.invoke('removeClassName', 'selected');
    lis[this.highlight_index].addClassName('selected');
  },

  // Fade out the quick results dialog
  hideQuickResults: function() {
    $$('#quicksearch_results').invoke('fade');
  },

  // Focus on the search box and select all
  focus: function() {
    $('searchbox').focus();
    $('searchbox').select();
  },

  // Send the search query through the controller, and fetch results
  submitSearch: function() {
    this.hideQuickResults();
    document.location.hash = "#!/search/"+escape($('searchbox').value);
  },

  // Perform an API call to fetch full search results in Sphinx
  // TODO: Should we move this into a collection?
  getResults: function(query) {
    // Populate searchbox if it's empty (because we loaded a search URL)
    if(!$('searchbox').value) { $('searchbox').value = query; }

    var self = this;
    var url = "/api/1/search/?q="+escape(query);
    var req = new Ajax.Request(url, {
      method: "get",
      onLoading: function(r) {
        // Display a placeholder for search
        $('content').update(
          self.loading_template({ query: query })
        );
        $('content').addClassName('search_results');
      },
      onComplete: function(r) {
        $('content').down('.loading').remove();
      },
      onSuccess: function(r) {
        var results = _.parseFromAPI(JSON.parse(r.responseText));
        self.displayResults(results);
      },
      onFailure: function(r) {
        $('search_result').update('<p>An error occurred, please try reloading the page.</p>');
      }
    });
  },

  // Render full search results
  displayResults: function(results) {
    var self = this;
    results.each(function(r) {
      r.icon_class = self.icons[r.type];
      r.name = (r.name || r.first_comment.stripTags()).truncate(65);
    });
    $('search_results').update(
      this.results_template({ results: results, length: results.length })
    );
  },

  icons: {
    "Conversation": 'comment_icon',
    "TaskList": 'task_icon',
    "Task": 'task_icon',
    "Page": 'page_icon'
  }

});
