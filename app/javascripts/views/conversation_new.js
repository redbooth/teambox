(function () {
  var ConversationNew = { template: Teambox.modules.ViewCompiler('conversations.new')
                     };

  ConversationNew.initialize = function (options) {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);

    var Views = Teambox.Views;
    this.convert_to_task = new Views.ConvertToTask({model: this.model});
    this.comment_form = new Views.CommentForm({
          model: this.model
        , convert_to_task: this.convert_to_task
        , controller: this.controller
        , url: this.model.postUrl()
    });
  },


  /* TODO: Handle 404s or permission denied for conversations
   * TODO: Shouldn't render to the DOM!
   */
  ConversationNew.render = function () {
    var html = this.template(this.model.getAttributes());
    this.el.update(html);

    // Render comment form
    this.comment_form.el = this.el.down('div.new_conversation');
    this.comment_form.render();
    //this.el.down('div.new_comment_wrap').insert({bottom: this.convert_to_task.render().el});

    return this;
  }

  // exports
  Teambox.Views.ConversationNew = Backbone.View.extend(ConversationNew);
}());
