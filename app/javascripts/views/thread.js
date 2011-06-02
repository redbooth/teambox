// This view renders a Conversation or Task as a thread
(function () {

  var Thread = { tagName: 'div'
               , className: 'thread'
               , template: Handlebars.compile(Templates.partials.thread)
               };

  Thread.initialize = function (options) {
    _.bindAll(this, "render");
    this.model.bind('comment:added', Thread.addComment.bind(this));
  };

  Thread.addComment = function (resp, user) {
    resp.user = user.attributes;

    var template = Handlebars.compile(Templates.partials.comment)
      , el = template(resp);

    this.el.select('.comments')[0]
      .insert({bottom: el})
      .childElements()
      .last()
      .highlight({duration: 1});

    // update excerpt
    this.el.down('.comment_header .excerpt')
           .update('<strong>' + resp.user.first_name + ' ' + resp.user.last_name + '</strong> ' + resp.body);

    // TODO: backbonize this [leftovers from comment.js]
    Task.insertAssignableUsers();
    my_user.stats.conversations++;
    document.fire("stats:update");
  };

  Thread.render = function () {
    var Views = Teambox.Views
      , convert_to_task = new Views.ConvertToTask({model: new Teambox.Models.Conversation(this.model.attributes)})
      , comment_form = new Views.CommentForm({ model: this.model, convert_to_task: convert_to_task});

    // Add data attributes to the DOM.
    this.el.writeAttribute({
      'data-class': this.model.get('type').toLowerCase()
    , 'data-id': this.model.get('id')
    , 'data-project-id': this.model.get('project_id')
    });

    // Introduce the is_task false attribute for thread rendering
    this.model.attributes.is_task = this.model.get('type') === 'Task';

    // Prepare the thread DOM element
    this.el.update(this.template(this.model.getAttributes()));

    // Insert the comment form at bottom of the thread element
    this.el.insert({ bottom: comment_form.render().el });
    if (this.model.isConversation()) {
      this.el.insert({bottom: convert_to_task.render().el});
    }

    return this;
  };

  // exports
  Teambox.Views.Thread = Backbone.View.extend(Thread);
}());
