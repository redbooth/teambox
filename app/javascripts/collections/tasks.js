Teambox.Collections.Tasks = Backbone.Collection.extend({
  model: Teambox.Models.Task,
  parse: function(response) {
    return _.parseFromAPI(response);
  },
  mine: function() {
    return this.filter( function(t) { 
      // FIXME: Should be person id, not user id
      return t.get('assigned_id') == my_user.id;
    });
  },
  url: function() {
    return "/api/1/tasks";
  }
});
