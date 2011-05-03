Teambox.Models.Project = Teambox.Models.Base.extend({
  initialize: function() {
  },
  render: function() {
  },
  url: function() {
    return "/api/1/projects/" + this.get('id');
  }
});

