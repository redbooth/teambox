Teambox.Collections.Tasks = Backbone.Collection.extend({
  model: Teambox.Models.Task,
  parse: function(response) {
    return _.parseFromAPI(response);
  },
  mine: function() {
    return this.filter( function(t) { 
      var assigned = t.get('assigned');
      return assigned && (assigned.user.id == my_user.id);
    });
  },
  url: function() {
    return "/api/1/tasks";
  }
});
