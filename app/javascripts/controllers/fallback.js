(function () {
  /* Extract text/html response from the parts.haml
   * layout and build a parts object */
  var extractParts = function(responseText) {
    if (!$('_extractor')) {
      $(document.body).insert({ bottom:
        "<div id='_extractor' style='display:none'></div>" });
    }
    var extractor = $('_extractor');
    extractor.insert({ top: responseText });
    var response = { body_classes: extractor.down(".body_classes").innerHTML
      , title: extractor.down(".title_part")
      , content: extractor.down(".content_part")
      , column: extractor.down(".column_part")
    };
    return response;
  };


  Teambox.Controllers.FallbackController = {
    show: function() {
      var current = Teambox.Views.Sidebar.detectSelectedSection(window.location.hash);
      Teambox.Views.Sidebar.highlightSidebar(current)

      var fragment = Backbone.history.fragment;

      new Ajax.Request(Backbone.history.fragment+"?extractparts=1", {
        method: "get",
        onSuccess: function(r) {
          // Insert the content, and update posted dates if necessary
          var parts = extractParts(r.responseText)

          document.body.className = parts.body_classes;
          $('content').update(parts.content);
          $('content').addClassName('ajax_forms');
          //$('column').update(parts.column);
          $('view_title').update(parts.title);


          Date.format_posted_dates();
          Task.insertAssignableUsers();
          disableConversationHttpMethodField();

        },
        onFailure: function(r) {
          // Force redirect if the AJAX load failed
          document.location = fragment;
        }
      })

    }
  }


  // Polite method overwriting, like rails alias_chain_method but for prototype
  Backbone.History.prototype.loadUrl = Backbone.History.prototype.loadUrl.wrap(function(proceed) {
    // proceed() normally if it fail run FallbackController
    if (proceed() == false) {
      Teambox.Controllers.FallbackController.show();
      var matched = true;
    } else {
      // Clear the body classes to avoid forms to act like ajax form
      $('content').removeClassName('ajax_forms');
    }
    return matched;
  })

  /* When a remote form is submitted in an ajax page, extract the response
   * and update the content div */
  document.on('ajax:complete', '.ajax_forms form', function(e, form) {
    var parts = extractParts(e.memo.responseText);
    $('content').update(parts.content);
  })

}());