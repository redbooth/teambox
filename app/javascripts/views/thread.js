// This view renders a Conversation or Task as a thread
(function () {

  var Thread = { tagName: 'div'
               , className: 'thread'
               , template: Handlebars.compile(Templates.partials.thread) };

  Thread.initialize = function (options) {
    _.bindAll(this, "render");
    this.model.bind('comment:added', Thread.addComment.bind(this));
  };

  Thread.addComment = function (resp) {
    resp.user = _.clone(Teambox.models.user.attributes);

    var template = Handlebars.compile(Templates.partials.comment)
      , el = template(resp);

    $(this.el)
      .select('.comments')[0]
      .insert({bottom: el})
      .highlight({duration: 1});
  };

  Thread.render = function () {
    var comment_form = new Teambox.Views.CommentForm({ model: this.model });

    // Add data attributes to the DOM.
    $(this.el).writeAttribute({
      'data-class': this.model.get('type').toLowerCase()
    , 'data-id': this.model.get('id')
    , 'data-project-id': this.model.get('project_id')
    });

    // Introduce the is_task false attribute for thread rendering
    this.model.attributes.is_task = this.model.get('type') === 'Task';

    // Prepare the thread DOM element
    $(this.el).update(this.template(this.model.getAttributes()));

    // Insert the comment form at bottom of the thread element
    // FIXME: This way of creating views could leak memory
    $(this.el).insert({ bottom: comment_form.render().el });

    return this;
  };

  // exports
  Teambox.Views.Thread = Backbone.View.extend(Thread);
}());
