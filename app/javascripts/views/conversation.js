(function () {
  var Conversation = { template: Teambox.modules.ViewCompiler('conversations.show')
                     , loading: Teambox.modules.ViewCompiler('partials.loading')
                     , comment_template: Teambox.modules.ViewCompiler('partials.comment')
                     };

  Conversation.initialize = function (options) {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
    this.title = 'Conversation ' + this.name;
  },


  /* TODO: Handle 404s or permission denied for conversations
   * TODO: Shouldn't render to the DOM!
   */
/*
  Conversation.render = function () {
    if(this.model.isLoaded()) {
      var html = this.template(this.model.getAttributes());
      this.el.update(html);
      var thread = this.el.down('.thread');
      if (thread) thread.remove();
      var threadView = new Teambox.Views.Thread({ model: this.model });
      this.el.insert({ bottom: threadView.render().el });
    } else {
      this.el.update(loading());
    }
    return this;
  }
*/
  Conversation.render = function () {
    if(this.model.isLoaded()) {
      var self = this;
      
      var html = this.template(this.model.getAttributes());
      this.el.update(html);
      
      var options = {
        conversation_id: this.model.id
      };
      
      comments = new Teambox.Collections.Comments([],options);
      
      // Show loader
      this.el.down('.comments').update("<img src='/images/loading.gif' alt='Loading' />");
      
      
      comments.fetch({
        success: function (collection) {
          var html = '';
          _.each(collection.models.reverse(), function (model) {
            html += self.comment_template(model.attributes);
          });
          self.el.down('.comments').update(html);
        }
      });
      

      
    } else {
      this.el.update(loading());
    }
    return this;
  };
  // exports
  Teambox.Views.Conversation = Backbone.View.extend(Conversation);
}());
