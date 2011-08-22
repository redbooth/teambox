(function () {
  /* Extract text/html response from the parts.haml
   * layout and build a parts object */
  var extractParts = function(responseText) {
    if (!$('_extractor')) {
      $(document.body).insert({ bottom:
        "<div id='_extractor' style='display:none'></div>" });
    }
    var extractor = $('_extractor');
    extractor.update(responseText);

    var isRedirect = !!extractor.down('.redirect');
    var parts = { redirect: isRedirect }
    if (isRedirect) {
      parts.redirectUrl  = extractor.down('.redirect').innerHTML
    } else {
      parts.body_classes = extractor.down(".body_classes").innerHTML
      parts.title        = extractor.down(".title_part").innerHTML
      parts.content      = extractor.down(".content_part").innerHTML
      parts.column       = extractor.down(".column_part").innerHTML
    }

    extractor.update('');

    var response = parts;
    globalParts = parts
    parts = null;
    return response;
  };

  var updateOrRedirect = function(parts) {
    if (parts.redirect == true) {
      Backbone.history.saveLocation(parts.redirectUrl);
      Backbone.history.loadUrl();
    } else {
      $('content').update(parts.content);
      $('content').addClassName(parts.body_classes);
      $('content').addClassName('ajax_forms');
      //$('column').update(parts.column);
      $('view_title').update(parts.title);
    }
  }

  Teambox.Controllers.FallbackController = {
    show: function() {
      var fragment = Backbone.history.getFragment().slice(2);

      $('content').update("<img src='/images/loading.gif'/> Loading...");

      new Ajax.Request(fragment, {
        method: "get",
        evalJS: false,
        evalJSON: false,
        parameters: {'extractparts' : 1 },
        onSuccess: function(r) {
          // Insert the content, and update posted dates if necessary
          var extractedParts = extractParts(r.responseText)
          updateOrRedirect(extractedParts);
        }
      })

      var current = Teambox.Views.Sidebar.detectSelectedSection(window.location.hash);
      if (current) {
        Teambox.Views.Sidebar.highlightSidebar(current)
      }

    }
  }


  // Polite method overwriting, like rails alias_chain_method but for prototype
  Backbone.History.prototype.loadUrl = Backbone.History.prototype.loadUrl.wrap(function(proceed) {
    // proceed() normally if it fail run FallbackController
    if (proceed() == false) {
      Teambox.Controllers.FallbackController.show();
    } else {
      // Clear the body classes to avoid forms to act like ajax form
      $('content').removeClassName('ajax_forms');
    }
    return true;
  })

  /* When a remote form is submitted in an ajax page, extract the response
   * and update the content div */
  document.on('ajax:complete', '.ajax_forms form', function(e, form) {
    var parts = extractParts(e.memo.responseText);
    updateOrRedirect(parts);
  })

}());
