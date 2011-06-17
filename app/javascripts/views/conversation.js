(function () {
  var Conversation = { template: Handlebars.compile(Templates.conversations.show)
                     , loading: Teambox.modules.ViewCompiler('partials.loading')
                     };

  Conversation.initialize = function (options) {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
  },


  /* TODO: Handle 404s or permission denied for conversations
   * TODO: Shouldn't render to the DOM!
   */
  Conversation.render = function () {
    if(this.model.isLoaded()) {
      var html = this.template(this.model.getAttributes());
      $('content').update(html);
      var thread = new Teambox.Views.Thread({ model: this.model });
      $('content').insert({ bottom: thread.render().el });
    } else {
      $('content').update(loading());
    }
  }

  // exports
  Teambox.Views.Conversation = Backbone.View.extend(Conversation);
}());
