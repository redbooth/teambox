Teambox.Views.Task = Backbone.View.extend({

  tagName: "div",

  //className: "task", FIXME: should use backbone's classname, not handlebar template's one

  template: Handlebars.compile(Templates.partials.task),

  events: {
    "click a.name": "expandComments",
    "click a.edit": "editTitle",
    "blur form.edit_title input": "updateTitle",
    "keyup form.edit_title input": "keyupTitle"
  },

  initialize: function() {
    _.bindAll(this, "render");
    this.model.bind('change', this.render);
  },

  render: function() {
    $(this.el).update(
      this.template(this.model.toJSON())
    );
    return this;
  },

  // Expand/collapse task comment threads inline
  expandComments: function(evt) {
    var task = $(this.el);

    var thread_block = task.down('.thread');
    if (task.hasClassName('expanded')) {
      var e1 = new Effect.BlindUp(thread_block, {duration: 0.3});
      var e2 = new Effect.Fade(task.down('.expanded_actions'), {duration: 0.3});
    } else {
      var e3 = new Effect.BlindDown(thread_block, {duration: 0.3});
      var e4 = new Effect.Appear(task.down('.expanded_actions'), {duration: 0.3});
      Date.format_posted_dates();
      Task.insertAssignableUsers();
    }
    task.toggleClassName('expanded');
    return false;
  },

  // Edit task's title inline
  editTitle: function(evt) {
    $(this.el).select('a.name, form.edit_title').invoke('toggle');
    $(this.el).down('form.edit_title input').focus();
    return false;
  },

  // Save the edited title when pressing Enter
  keyupTitle: function(evt) {
    if (evt.keyCode == 13) {
      this.updateTitle(evt);
      return false;
    }
  },

  // Start an AJAX request to update the task's title
  updateTitle: function(evt) {
    var old = $(this.el).down('a.name').innerHTML;
    var now = $(this.el).down('form.edit_title input').value;

    // Update only if the title is dirty
    if( now != old ) {
      $(this.el).down('a.name').update("Saving... (not implemented yet)");
    }

    $(this.el).select('a.name, form.edit_title').invoke('toggle');
    return false;
  }
});
