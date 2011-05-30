(function () {

  var CommentForm = {
    tagName: 'form'
  , className: 'new_comment'
  , template: Handlebars.compile(Templates.partials.comment_form)
  , events: {
      'click a.attach_icon'    : 'toggleAttach'
    , 'click a.add_hours_icon' : 'toggleHours'
    , 'click a.add_watchers'   : 'toggleWatchers'
    , 'focusin textarea'         : 'revealCommentArea'
    }
  };

  CommentForm.initialize = function (options) {
    this.app = options.app;
    _.bindAll(this, "render");
    // Fixme: bind to changes
  };

  // Build a form DOM element, that will be used by other views
  CommentForm.render = function () {
    $(this.el).writeAttribute({
      'accept-charset': 'UTF-8'
    , 'action': this.model.get('url')
    , 'data-project-id': this.model.get('project_id')
    , 'data-remote': 'true'
    , 'enctype': 'multipart/form-data'
    , 'method': 'post'
    });

    $(this.el).addClassName("edit_" + this.model.get('type').toLowerCase());
    $(this.el).update(this.template(this.model.getAttributes()));

    return this;
  };

  // Toggle the attach files area
  CommentForm.toggleAttach = function (evt) {
    $(this.el).down('.upload_area').toggle().highlight();
    return false;
  };

  // Toggle the time tracking area
  CommentForm.toggleHours = function (evt) {
    $(this.el).down('.hours_field').toggle().down('input').focus();
    return false;
  };

  // Toggle the "Add Watchers" area
  CommentForm.toggleWatchers = function (evt) {
    var watchers = $(this.el).down('.add_watchers_box');
    if (watchers) {
      // Remove the box if there is one already
      watchers.remove();
    } else {
      // Render it if it's not there
      watchers = new Teambox.Views.Watchers({ model: this.model });
      $(this.el).down('.actions').insert({ before: watchers.render().el });
    }
    return false;
  };

  // Reveal the extra controls when focusing on the textarea
  CommentForm.revealCommentArea = function (evt) {
    $(this.el).down('.extra').show();
  };

  // exports
  Teambox.Views.CommentForm = Backbone.View.extend(CommentForm);
}());
