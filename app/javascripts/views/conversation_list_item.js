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
        jQuery(self.el).addClass('active');
      else
        jQuery(self.el).removeClass('active');
    });
    this.model.bind('change', this.render);
  };

  ConversationListItem.setConversation = function() {
    this.root_view.setActive(this.model);
    document.location.hash = '!/projects/' + this.root_view.project_id + '/conversations/' + this.model.id;
  };


  // Shorten a string adding '...' at the end
  _shorten = function(comment, max_lenght) {
    if(comment.length > max_lenght) {
      comment = comment.substr(0, max_lenght)
      var last_space = comment.lastIndexOf(' ');
      comment = comment.substr(0, last_space) + '...'; 
    }
    return comment;
  };

  ConversationListItem.render = function () {	
    this.el.className = 'conversation';
    if(this.model.isLoaded()) {

      var first_comment = _shorten(this.model.get('first_comment').body.stripTags(), 40);

      // Generate commenters string
      var commenters = [];
      commenters.push(this.model.get('first_comment').user.username);
      var recent_comments = this.model.get('recent_comments');
      recent_comments[0] && commenters.push(recent_comments[0].user.username);
      recent_comments[1] && commenters.push(recent_comments[1].user.username);
      commenters = _.uniq(commenters);
      var commenters_s = commenters[0];
      _.each(commenters.splice(1), function(commenter) { return commenters_s += ', ' + commenter});

      var html = this.template({
        name: this.model.get('name')
      , first_comment: first_comment
      , commenters: commenters_s
      });

      jQuery(this.el).html(html);
    } else {
      jQuery(this.el).html(loading());
    }
    return this;
  };

  // exports
  Teambox.Views.ConversationListItem = Backbone.View.extend(ConversationListItem);
}());
