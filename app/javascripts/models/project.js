Teambox.Models.Project = Backbone.Model.extend({
  initialize: function() {
  },
  render: function() {
  },
  url: function() {
    return "/api/1/projects/" + this.get('id');
  }
});

