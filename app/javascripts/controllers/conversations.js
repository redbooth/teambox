Teambox.Controllers.ConversationsController = Backbone.Controller.extend({
  routes: {
    '/projects/:project/conversations'     : 'conversations_index',
    '/projects/:project/conversations/:id' : 'conversations_show'
  },

  conversations_new: function() {
    $('content').update( Handlebars.compile(Templates.conversations['new'])() );
  },

  // Display 'loading', fetch the conversation and display it
  conversations_show: function(project, id) {
    var model = new Teambox.Models.Conversation({ id: id });
    var view = new Teambox.Views.Conversation({ model: model });
    view.render();
    model.fetch();
  }

});


_.extend(Teambox.Controllers.ConversationsController.prototype, Teambox.Views.Utility);
