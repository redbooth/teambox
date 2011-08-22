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
  , 'click a.search_btn':           'submitSearch'
  }

  /* Updates current el
   *
   * @return self
   */
  Search.render = function () {
    jQuery(this.el).html(this.template());
    return this;
  };

  /* Keyboard navigation for quick results
   *
   * @param {Event} evt
   */
  Search.reset = function (evt) {
    jQuery('searchbox').empty();
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
        var a = jQuery('#quicksearch_results li.selected a');
        document.location = a.attr('href');
        this.hideQuickResults();
        jQuery('#searchbox').blur();
      }
      evt.preventDefault();
      return;
    }

    // Close the search box when clicking Esc
    if (evt.keyCode === Event.KEY_ESC) {
      this.hideQuickResults();
      jQuery('#searchbox').blur();
      evt.preventDefault();
      return;
    }

    // Prevent up/down cursor actions on the input
    if (evt.keyCode === Event.KEY_UP) {
      evt.preventDefault();
      return;
    }

    if (evt.keyCode === Event.KEY_DOWN) {
      evt.preventDefault();
      return;
    }
  };

  /* Display the 20 most recent matching results
   *
   * @param {Event} evt
   */
  Search.showQuickResults = function (evt) {
    var search_term = jQuery('#searchbox').val();

    // If text search is empty, hide the results box
    if (search_term.length === 0) {
      this.hideQuickResults();
      return evt.preventDefault();
    }

    var threads = Teambox.collections.threads
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
      return evt.preventDefault();
    }

    if (evt.keyCode === Event.KEY_ESC) {
      return evt.preventDefault();
    }

    // Move highlighted element up or down, if possible
    if (evt.keyCode === Event.KEY_UP) {
      this.moveHighlight(-1);
      return evt.preventDefault();
    }

    if (evt.keyCode === Event.KEY_DOWN) {
      this.moveHighlight(1);
      return evt.preventDefault();
    }

    // Display the dropdown menu with results
    jQuery('#quicksearch_results').remove();
    var html = this.quickresult_template({results: found, query: search_term});
    jQuery(document.body).prepend(html);
    this.highlight_index = 0;

    // Highlight matches in results
    jQuery('#quicksearch_results li a').each(function (i,a) {
      var regex = new RegExp(search_term, 'ig');
      a.innerHTML = a.innerHTML.replace(regex, "<b>$&</b>");
    });
  };

  /* Move the highlighted index in quick results up and down
   *
   * @param {Integer} inc
   */
  Search.moveHighlight = function (inc) {
    var lis = jQuery('#quicksearch_results li');

    if (jQuery('#quicksearch_results').length === 0) { return; }

    this.highlight_index = (this.highlight_index + inc) || 0;
    this.highlight_index = [0, this.highlight_index].max();
    this.highlight_index = [lis.length - 1, this.highlight_index].min();

    lis.removeClass('selected');
    lis.eq(this.highlight_index).addClass('selected');
  };

  /* Fade out the quick results dialog
   */
  Search.hideQuickResults = function () {
    jQuery('#quicksearch_results').fadeOut(200);
  };

  /* Focus on the search box and select all
   */
  Search.focus = function () {
    jQuery('#searchbox').focus().select();
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
    if (!$('searchbox').val()) {
      $('searchbox').val(query);
    }

    var self = this
      , url = "/api/1/search/?q=" + escape(query);

    new Ajax.Request(url, {
      method: 'get'
    , onLoading: function (r) {
        // Display a placeholder for search
        jQuery('#content')
          .html(self.loading_template({ query: query }))
          .addClass('search_results');
      }
    , onComplete: function (r) {
        jQuery('#content .loading').remove();
      }
    , onSuccess: function (r) {
        var results = _.parseFromAPI(JSON.parse(r.responseText));
        self.displayResults(results);
      }
    , onFailure: function (r) {
        jQuery('#search_result').html('<p>An error occurred, please try reloading the page.</p>');
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

    jQuery('#search_results').html(
      this.results_template({results: results, length: results.length})
    );
  };

  // exports
  Teambox.Views.Search = Backbone.View.extend(Search);
}());
