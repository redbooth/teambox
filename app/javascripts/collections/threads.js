Teambox.Collections.Threads = Backbone.Collection.extend({
  model: Teambox.Models.Thread,
  parse: function(response) {
    var activities = _.parseFromAPI(response);

    // Extract unique threads from activities,
    // grouping tasks and conversations 
    var threads = activities.collect(function(o) {
      if (o.target.type == "Comment") {
        return o.target.target;
      } else if(o.target.type == "Task" || o.target.type == "Conversation") {
        return o.target;
      } else {
        return o;
      }
    }).compact().uniq();

    return threads;
  },
  url: function() {
    return "/api/1/activities";
  }
});
