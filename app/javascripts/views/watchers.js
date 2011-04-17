// This is the Add Watchers view that you get when replying in a thread

Teambox.Views.Watchers = Backbone.View.extend({

  className: "add_watchers_box",

  template: Handlebars.compile(Templates.partials.add_watchers),

  initialize: function() {
    _.bindAll(this, "render");
  },

  // Draw the Add Watchers box and populate it with watchers
  render: function() {
    $(this.el).update(
      // using fake data for users, should use project's users
      this.template({ users: [Teambox.my_user.toJSON()] })
    );
    // TODO: Add the list of people in the project here
    return this;
  },


  /////////////////////////////////////////////////////////////////////////////
  // Event handling

  events: {
    "click .watcher a": "addWatcher"
  },

  // Add @username to the textarea when clicking on a user
  addWatcher: function(evt) {
    var el = evt.currentTarget;
    var textarea = el.up("form").down("textarea");
    var login = el.readAttribute('data-login');
    if (textarea.value.length > 0 && textarea.value[textarea.value.length-1] != " ") {
      textarea.value += " ";
    }
    textarea.value += "@"+login+" ";
    return false;
  }

});
