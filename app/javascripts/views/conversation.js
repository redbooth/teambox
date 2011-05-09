Teambox.Views.Conversation = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
  },

  template: Handlebars.compile(Templates.conversations.show),
  loading: Templates.partials.loading,

  // TODO: Handle 404s or permission denied for conversations

  // Display the conversation (or a loading box while it's loading)
  render: function() {
    if(this.model.isLoaded()) {
      var html = this.template(this.model.toJSON());
      $('content').update(html);
      var thread = new Teambox.Views.Thread({ model: this.model });
      $('content').insert({ bottom: thread.render().el });
    } else {
      $('content').update(Templates.partials.loading);
    }
  }

});
