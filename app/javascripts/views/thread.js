// This view renders a Conversation or Task as a thread

Teambox.Views.Thread = Backbone.View.extend({

  tagName: "div",
  className: "thread",

  template: Handlebars.compile(Templates.partials.thread),

  initialize: function() {
    _.bindAll(this, "render");
    // Fixme: bind to changes
  },

  render: function() {
    // Add data attributes to the DOM.
    $(this.el).writeAttribute({
      "data-class": this.model.get('type').toLowerCase(),
      "data-id": this.model.get('id'),
      "data-project-id": this.model.get('project_id')
    });

    // Introduce the is_task false attribute for thread rendering
    this.model.attributes.is_task = this.model.get('type') == 'Task';

    // Prepare the thread DOM element
    $(this.el).update(
      this.template(this.model.toJSON())
    );

    // Insert the comment form at bottom of the thread element
    // FIXME: This way of creating views could leak memory
    var comment_form = new Teambox.Views.CommentForm({ model: this.model });
    $(this.el).insert({ bottom: comment_form.render().el });

    return this;
  }

});
