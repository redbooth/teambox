(function () {
  var ConversationListItem = { 	tagName: 'div'
                     , className: 'conversation'
                     , template: Teambox.modules.ViewCompiler('conversations.show_list')
                     , loading: Teambox.modules.ViewCompiler('partials.loading')
                     };

  ConversationListItem.events = {
    'click': 'setConversation'
  };

  ConversationListItem.initialize = function (options) {
    var self = this;
    _.bindAll(this, 'render');
    this.root_view = options.root_view;
    this.root_view.bind('change_selection', function(conversation){
      if (self.model.id == conversation.id)
        self.el.addClassName('active');
      else
        self.el.removeClassName('active');
    });
    this.model.bind('change', this.render);
  };
  
  ConversationListItem.setConversation = function() {
    this.root_view.setActive(this.model);
    document.location.hash = '!/projects/' + this.root_view.project_id + '/conversations/' + this.model.id;
  };
  
  ConversationListItem.render = function () {	
    this.el.className = 'conversation';
    if(this.model.isLoaded()) {
      var html = this.template({model: this.model});
      this.el.update(html);
    } else {
      this.el.update(loading());
    }
    return this;
  };

  // exports
  Teambox.Views.ConversationListItem = Backbone.View.extend(ConversationListItem);
}());
