(function  () {
  var Search = { className: 'search_bar'
               , template: Teambox.modules.ViewCompiler('partials.search_bar')
               , quickresult_template: Teambox.modules.ViewCompiler('search.quicksearch')
               , loading_template: Teambox.modules.ViewCompiler('search.loading')
               , results_template: Teambox.modules.ViewCompiler('search.results')
               ,  icons: { Conversation: 'comment_icon'
                         , TaskList: 'task_icon'
                         , Task: 'task_icon'
                         , Page: 'page_icon'
                         }
               };

  Search.events = {
    'keydown input#searchbox':      'navigateQuickResults'
  , 'keyup input#searchbox':        'showQuickResults'
  , 'focus input#searchbox':        'focus'            // Y U NO WORK?
  , 'click #quicksearch_results a': 'reset'            // Y U NO WORK?
  , 'focusout input#searchbox':     'hideQuickResults'
  }

  /* Updates current el
   *
   * @return self
   */
  Search.render = function () {
    this.el.update(this.template());
    return this;
  };

  /* Keyboard navigation for quick results
   *
   * @param {Event} evt
   */
  Search.reset = function (evt) {
    $('searchbox').value = '';
  }

  /* Keyboard navigation for quick results
   *
   * @param {Event} evt
   */
  Search.navigateQuickResults = function (evt) {
    if (evt.keyCode === Event.KEY_RETURN) {
      // Run full search, and prevent submitting the form
      if (this.highlight_index === 0) {
        this.submitSearch();
      } else { // or navigate to the selected element
        var a = $('quicksearch_results').down('li.selected a');
        document.location = a.readAttribute('href');
        this.hideQuickResults();
        $('searchbox').blur();
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
    if (evt.keyCode === Event.KEY_UP) {
      return evt.stop();
    }

    if (evt.keyCode === Event.KEY_DOWN) {
      return evt.stop();
    }
  };

  /* Display the 20 most recent matching results
   *
   * @param {Event} evt
   */
  Search.showQuickResults = function (evt) {
    var search_term = $('searchbox').value
      , threads = Teambox.collections.threads
      , pages = Teambox.collections.pages
      , projects = Teambox.collections.projects
      , people = Teambox.collections.people
      , regex = RegExp(search_term, 'i')
      , found = threads.models.concat(pages.models).concat(projects.models).concat(people.models).select(function (el) {
          return el.get('name') && regex.test(el.get('name')) || (el.get('type') === 'Person' && el.get('user').username && regex.test(el.get('user').username));
        }).sortBy(function (el) {
          return el.get('updated_at');
        }).sortBy(function (el) {
          // Show Projects on top
          return el.get('type') == "Project" ? 0 : 1;
        }).slice(0, 20).collect(function (el) {
          return el.getAttributes();
        });

    // Ignore Enter and Esc, since they are already handled on keydown
    if (evt.keyCode === Event.KEY_RETURN) {
      return evt.stop();
    }

    if (evt.keyCode === Event.KEY_ESC) {
      return evt.stop();
    }

    // Move highlighted element up or down, if possible
    if (evt.keyCode === Event.KEY_UP) {
      this.moveHighlight(-1);
      return evt.stop();
    }

    if (evt.keyCode === Event.KEY_DOWN) {
      this.moveHighlight(1);
      return evt.stop();
    }

    // If text search is empty, hide the results box
    if (search_term.length === 0) {
      this.hideQuickResults();
    }

    // Display the dropdown menu with results
    $$('#quicksearch_results').invoke('remove');
    $(document.body).insert({top: this.quickresult_template({results: found, query: search_term})});
    this.highlight_index = 0;

    // Highlight matches in results
    $$('#quicksearch_results li a').each(function (a) {
      var regex = new RegExp(search_term, 'ig');
      a.innerHTML = a.innerHTML.replace(regex, "<b>$&</b>");
    });
  };

  /* Move the highlighted index in quick results up and down
   *
   * @param {Integer} inc
   */
  Search.moveHighlight = function (inc) {
    var lis = $('quicksearch_results').select('li');

    if (!$('quicksearch_results')) {
      return;
    }

    this.highlight_index = (this.highlight_index + inc) || 0;
    this.highlight_index = [0, this.highlight_index].max();
    this.highlight_index = [lis.length - 1, this.highlight_index].min();

    lis.invoke('removeClassName', 'selected');
    lis[this.highlight_index].addClassName('selected');
  };

  /* Fade out the quick results dialog
   */
  Search.hideQuickResults = function () {
    $$('#quicksearch_results').invoke('fade', { duration: 0.2 });
  };

  /* Focus on the search box and select all
   */
  Search.focus = function () {
    $('searchbox').focus();
    $('searchbox').select();
  };

  /* Send the search query through the controller, and fetch results
   */
  Search.submitSearch = function () {
    this.hideQuickResults();
    document.location.hash = "#!/search/" + escape($('searchbox').value);
  };

  /* Perform an API call to fetch full search results in Sphinx
   * TODO: Should we move this into a collection?
   *
   * @param {String} query
   */
  Search.getResults = function (query) {
    // Populate searchbox if it's empty (because we loaded a search URL)
    if (!$('searchbox').value) {
      $('searchbox').value = query;
    }

    var self = this
      , url = "/api/1/search/?q=" + escape(query);

    new Ajax.Request(url, {
      method: 'get'
    , onLoading: function (r) {
        // Display a placeholder for search
        $('content').update(
          self.loading_template({ query: query })
        );
        $('content').addClassName('search_results');
      }
    , onComplete: function (r) {
        $('content').down('.loading').remove();
      }
    , onSuccess: function (r) {
        var results = _.parseFromAPI(JSON.parse(r.responseText));
        self.displayResults(results);
      }
    , onFailure: function (r) {
        $('search_result').update('<p>An error occurred, please try reloading the page.</p>');
      }
    });
  };

  /* Render full search results
   *
   * @param {Array} results
   */
  Search.displayResults = function (results) {
    var self = this;

    results.each(function (r) {
      r.icon_class = self.icons[r.type];
      r.name = (r.name || r.first_comment.stripTags()).truncate(65);
    });

    $('search_results').update(
      this.results_template({results: results, length: results.length})
    );
  };

  // exports
  Teambox.Views.Search = Backbone.View.extend(Search);
}());
