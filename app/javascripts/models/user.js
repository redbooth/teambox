Teambox.Models.User = Backbone.Model.extend({
  initialize: function () {
    this.bind('change:username', this.onRename);
  },
  onRename: function () {
    this.render();
    return this;
  },
  username_template: "<a href='/users/{{username}}'>{{username}}</a>",
  render: function() {
    var html = Mustache.to_html(this.username_template, this.toJSON());
    $('username').update(html);
    return this;
  },
  url: function() {
    return "/api/1/account";
  }
});

