(function () {
  var ConversationsController = { routes: { '/projects/:project/conversations'     : 'index'
                                          , '/projects/:project/conversations/new' : 'new'
                                          , '/projects/:project/conversations/:id' : 'show'}};

  ConversationsController['new'] = function (project) {
    var collection = Teambox.collections.conversations;
    var conversation = new Teambox.Models.Conversation();
    var view = new Teambox.Views.ConversationList({collection: collection, conversation: conversation, project_id: project});
    $('content').update(view.render().el);
  };

    // Display 'loading', fetch the conversation and display it
  ConversationsController.show = function (project, id) {
    var model = Teambox.collections.conversations.get(id);

    if (!model) {
      model = new Teambox.Models.Conversation({ id: id });
      model.fetch();
    }
    
    var collection = Teambox.collections.conversations;
    var view = new Teambox.Views.ConversationList({collection: collection, conversation: model, project_id: project});
    $('content').update(view.render().el);

    view.setActive(model);

    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_conversations');
    $('view_title').update(view.title);
  };

  ConversationsController.index = function (project, id) {
    var collection = Teambox.collections.conversations;
    var view = new Teambox.Views.ConversationList({collection: collection, project_id: project});
    $('content').update(view.render().el);

    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_conversations');
    $('view_title').update(view.title);
  };

  // exports
  Teambox.Controllers.ConversationsController = Teambox.Controllers.BaseController.extend(ConversationsController);
}());
