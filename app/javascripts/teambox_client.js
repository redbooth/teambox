//
// Renders the activity feed from an API request
//

TeamboxClient = {
  init: function() {
    // Register helpers
    Handlebars.registerPartial("comment", Templates.partials.comment);
    Handlebars.registerPartial("thread", Templates.partials.thread);
    Handlebars.registerPartial("comment_form", Templates.partials.comment_form);
    Handlebars.registerHelper('downcase', function(str) {
      return str.toLowerCase();
    });
    Handlebars.registerHelper('host', 'http://l.teambox.com');
    Handlebars.registerHelper('full_name', function(user) {
      user = user || this;
      return user.first_name + " " + user.last_name;
    });
    Handlebars.registerHelper('ms', function(time) {
      return Date.parse(time);
    });
    // Render status transitions in comments
    Handlebars.registerHelper('status_transition', function() {
      var status = $w('new open hold resolved rejected').collect(function(s) {
        return '<span class="task_status task_status_'+s+'">'+s+'</span>';
      });
      var before = status[this.previous_status];
      var now = status[this.status];
      var html = [before, now].compact().join('<span class="arr status_arr"> &rarr; </span>');
      return new Handlebars.SafeString(html);
    });
  },
  renderActivities: function(json) {
    this.init();

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
      onSuccess: function(r) {
        console.log(r.responseJSON);
      },
      onCreate: function(response) {
        $('content').insert({ 
          top: "<img src='/images/loading.gif'> Loading activities"
        });
      },
      onFailure: function(response) {
        console.log("1: fail", response, response.responseJSON);
      },
      onComplete: function(response) {
        console.log("1: complete", response, response.responseJSON);
      }
    });
  }
};

