Teambox.Models.Task = Backbone.Model.extend({
  initialize: function() {
  },
  render: function() {
  },
  url: function() {
    return "/api/1/tasks/" + this.get('id');
  }
});
