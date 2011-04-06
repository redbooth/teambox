Teambox.Collections.Tasks = Backbone.Collection.extend({
  model: Teambox.Models.Task,
  parse: function(response) {
    return _.parseFromAPI(response);
  },
  url: function() {
    return "/api/1/tasks";
  }
});
