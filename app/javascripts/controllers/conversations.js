Teambox.Controllers.ConversationsController = Teambox.Controllers.BaseController.extend({
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

    // Try to find this element in the Threads collection
    var found_element = _.findFromCollection(Teambox.my_threads, id, "Conversation");

    if (found_element) {
      // Set the element on the view
      model.set(found_element);
    } else {
      // Display "loading" and fetch the element, which will trigger the view
      view.render();
      model.fetch();
    }
 }

});
