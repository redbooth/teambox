(function () {
  var Conversation = { template: Teambox.modules.ViewCompiler('conversations.show')
                     , loading: Teambox.modules.ViewCompiler('partials.loading')
                     , comment_template: Teambox.modules.ViewCompiler('partials.comment')
                     };

  Conversation.initialize = function (options) {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
    this.title = 'Conversation ' + this.name;
    
    
    this.model.bind('comment:added', this.addComment.bind(this));
    // this.model.bind('comment:added', this.updateThreadAttributes.bind(this));
    
    var Views = Teambox.Views;
    this.convert_to_task = new Views.ConvertToTask({model: this.model});
    this.comment_form = new Views.CommentForm({
          model: this.model
        , convert_to_task: this.convert_to_task
        , controller: this.controller
    });
  },


  /* TODO: Handle 404s or permission denied for conversations
   * TODO: Shouldn't render to the DOM!
   */
  Conversation.render = function () {
    var self = this;
    
    if(this.model.isLoaded()) {
      
      var html = this.template(this.model.getAttributes());
      this.el.update(html);
      
      var options = {
        conversation_id: this.model.id
      };
      
      comments = new Teambox.Collections.Comments([], options);
      
      // Show loader
      this.el.down('.comments').update("<img src='/images/loading.gif' alt='Loading' />");
      
      comments.fetch({
        success: function (collection) {
          var html = '';
          _.each(collection.models.reverse(), function (model) {
            html += self.comment_template(model.attributes);
          });
          self.el.down('.comments').update(html);
          self.comment_form.el.show();
        }
      });
      
      // Render comment form
      this.comment_form.el = this.el.down('div.new_comment_wrap').hide();
      this.comment_form.render();
      this.el.down('div.new_comment_wrap').insert({bottom: this.convert_to_task.render().el});
      
    } else {
      
      // TODO: loader() is not defined
      this.el.update(loading());
    }
    return this;
  };
  
  Conversation.addComment = function(comment) {
    var el = this.comment_template(comment);
    
    this.el
      .select('.comments')[0]
      .insert({ bottom: el })
      .childElements()
      .last()
      .highlight({duration: 1});
  };
  
  // exports
  Teambox.Views.Conversation = Backbone.View.extend(Conversation);
}());
