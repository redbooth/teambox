// This view renders a Conversation or Task as a thread
(function () {

  var ConversationList = { tagName: 'div'
               , className: 'conversations'
               , template: Teambox.modules.ViewCompiler('conversations.index')
               };

  ConversationList.events = {};

  ConversationList.initialize = function (options) {
    _.bindAll(this, "render");
    this.collection.bind('add', this.addConversation);
    this.collection.bind('remove', this.removeConversation);
    this.collection.bind('refresh', this.reload);
    
    // Get real complete name of project
    var project = Teambox.collections.projects.detect(function(model) {
      return model.get('permalink') === options.project_id;
    });
    
    this.title = 'Conversations on ' + project.get('name');
    this.project_id = options.project_id;
    this.conversation = options.conversation;
  };

  ConversationList.addConversation = function(conversation, collection) {
    this.conversationList.insert({top: new Teambox.Views.Conversation({model:thread, root_view: this}).render().el});
  };

  ConversationList.removeConversation = function(conversation, collection) {
    this.conversationList.find('.conversation[data-class=conversation, data-id='+conversation.id+', data-project-id='+conversation.get('project_id')+']').remove();
  };

  ConversationList.setActive = function(model) {
    this.current_conversation = model;
    this.trigger('change_selection', model);
  };

  ConversationList.reload = function(collection, project_id) {
    var self = this;
    // Only add them to the DOM if their project_id matches
    collection.each(function(conversation){
      if(conversation.get('project').permalink === project_id){
        var view = new Teambox.Views.ConversationListItem({model:conversation, root_view: self});
        self.conversation_list.insert({bottom: view.render().el});
      }
    });
  };

  ConversationList.render = function () {
    var Views = Teambox.Views, self = this;
    this.el.update(this.template({project_id: this.project_id}));
    this.conversation_list = this.el.down('.conversation_list');
    this.conversation_view = this.el.down('.conversation_view');
    this.reload(this.collection, this.project_id);
    if (this.conversation) {
      var view;
      if (this.conversation.id == null) {
        view = new Teambox.Views.ConversationNew({model: this.conversation});
      } else {
        view = new Teambox.Views.Conversation({model: this.conversation});
      }
      this.conversation_view.update(view.render().el);
    }
    return this;
  };

  // exports
  Teambox.Views.ConversationList = Backbone.View.extend(ConversationList);
}());