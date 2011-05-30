Teambox.Models.User = Teambox.Models.Base.extend({

  // Listen for changes in the username field
  initialize: function () {
    _.bindAll(this, 'render');
    this.bind('change:username', this.render);
  },

  username_template: Handlebars.compile(
    "<a href='/users/{{username}}'>{{username}}</a>"
  ),

  // Updates the username link on the header
  render: function() {
    $('username').update(
      this.username_template(this.getAttributes())
    );
    return this;
  },

  url: function() {
    return "/api/1/account";
  }

});

