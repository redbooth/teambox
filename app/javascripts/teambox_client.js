//
// Renders the activity feed from an API request
//

TeamboxClient = {
  renderActivities: function(json) {
    // Parse the API response object, fetching references
    var activities = _.parseFromAPI(json);

    var thread_template = Handlebars.compile(Templates.activities.feed);

    // Extract threads (only) and render them uniquely
    var threads = activities.collect(function(o) {
      if (o.target.type == "Comment") {
        return o.target.target;
      } else if(o.target.type == "Task" || o.target.type == "Conversation") {
        return o.target;
      } else {
        return o;
      }
    }).compact().uniq();

    $('content').insert({ top: thread_template({ threads: threads }) });
  },
  fetchAndRenderActivities: function() {
    // The following code renders the activity feed from the API
    var r = new Ajax.Request("/api/1/activities.js?callback=TeamboxClient.renderActivities", {
      method: 'get',
      requestHeaders: { Accept: 'application/json' },
      onCreate: function(response) {
        $('content').insert({ 
          top: "<img src='/images/loading.gif'> Loading activities"
        });
      }
    });
  }
};

