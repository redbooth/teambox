(function () {
  var ConversationNew = { template: Teambox.modules.ViewCompiler('conversations.new')
                     };

  ConversationNew.initialize = function (options) {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
    this.title = 'Conversation ' + this.name;
  },


  /* TODO: Handle 404s or permission denied for conversations
   * TODO: Shouldn't render to the DOM!
   */
  ConversationNew.render = function () {
    var html = this.template(this.model.getAttributes());
    this.el.update(html);
    return this;
  }

  // exports
  Teambox.Views.ConversationNew = Backbone.View.extend(ConversationNew);
}());
