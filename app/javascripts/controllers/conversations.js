(function () {
  var ConversationsController = { routes: { '/projects/:project/conversations'     : 'index'
                                          , '/projects/:project/conversations/:id' : 'show' }};

  ConversationsController['new'] = function () {
    $('content').update( Handlebars.compile(Templates.conversations['new'])() );
  };

    // Display 'loading', fetch the conversation and display it
  ConversationsController.show = function (project, id) {
    var model = Teambox.collections.conversations.get(id);

    if (!model) {
      model = new Teambox.Models.Conversation({ id: id });
      model.fetch();
    }

    $('content').update((new Teambox.Views.Thread({model: model})).render().el);

    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_conversations');
  };

  ConversationsController.index = function (project, id) {
    var collection = Teambox.collections.conversations;
    $('content').update((new Teambox.Views.ThreadList({collection: collection})).render().el);

    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_conversations');
  };

  // exports
  Teambox.Controllers.ConversationsController = Teambox.Controllers.BaseController.extend(ConversationsController);
}());
