(function () {
  var Conversation = { template: Teambox.modules.ViewCompiler('conversations.show')
                     , loading: Teambox.modules.ViewCompiler('partials.loading')
                     , comment_template: Teambox.modules.ViewCompiler('partials.comment')
                     };

  Conversation.initialize = function (options) {
    _.bindAll(this, 'render');
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
  };


  /* TODO: Handle 404s or permission denied for conversations
   * TODO: Shouldn't render to the DOM!
   */
  Conversation.render = function () {
    var self = this;
    if(this.model.isLoaded()) {
      var html = this.template(this.model.getAttributes());
      jQuery(this.el).html(html);
      var options = {
        conversation_id: this.model.id
      };
      comments = new Teambox.Collections.Comments([], options);

      // Show loader
      this.$('.comments').html("<img src='/images/loading.gif' alt='Loading' />");

      comments.fetch({
        success: function (collection) {
          var html = '';
          _.each(collection.models.reverse(), function (model) {
            html += self.comment_template(model.attributes);
          });
          self.$('.comments').html(html);
          self.comment_form.el.show();
        },
        error: function(c, r) {
          self.showError.call(self, r);
        }
      });

      // Render comment form
      this.comment_form.el = this.$('div.new_comment_wrap').hide();
      this.comment_form.render();
      this.$('div.new_comment_wrap').append( this.convert_to_task.render().el );

    } else {

      // TODO: loader() is not defined
      jQuery(this.el).html(loading());
    }
    return this;
  };

  Conversation.addComment = function(comment) {
    var el = this.comment_template(comment);

    this.$('.comments').append(el);
      //.childElements().last().highlight({duration: 1});
  };

  Conversation.showError = function(r) {
    jQuery(this.el).html('<div class="error">Error: ' + r.responseText.evalJSON().errors.message + '</div>');
  };

  // exports
  Teambox.Views.Conversation = Backbone.View.extend(Conversation);
}());
