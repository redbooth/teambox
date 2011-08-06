(function () {
  Teambox.Controllers.FallbackController = {
    show: function() {
      var fragment = Backbone.history.fragment;

      new Ajax.Request(Backbone.history.fragment+"?extractparts=1", {
        method: "get",
        onSuccess: function(r) {
          var extractParts = function(responseText) {
            if (!$('_extractor')) {
              $(document.body).insert({ bottom:
                "<div id='_extractor' style='display:none'></div>" });
            }
            var extractor = $('_extractor');
            extractor.insert({ top: responseText });
            var response = {
              body_classes: extractor.down(".body_classes").innerHTML,
              content: extractor.down(".content_part"),
              column: extractor.down(".column_part")
            };
            return response;
          };

          var current = Teambox.Views.Sidebar.detectSelectedSection(window.location.hash);
          Teambox.Views.Sidebar.highlightSidebar(current)

          // Insert the content, and update posted dates if necessary
          var parts = extractParts(r.responseText)
          if (!parts.content)
            return this.onFailure(r);

          document.body.className = parts.body_classes;
          $('content').update(parts.content);
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

Backbone.History.prototype.loadUrl = Backbone.History.prototype.loadUrl.wrap( 
  function(proceed) {

    if (proceed() == false) {
      Teambox.Controllers.FallbackController.show();
      var matched = true;
    }

    return false;
  })
}());