// This view renders a Conversation or Task as a thread
(function () {

  var ThreadList = { tagName: 'div'
               , className: 'threads'
               };

  ThreadList.events = {};

  ThreadList.initialize = function (options) {
    _.bindAll(this, "render");
    this.collection.bind('add', this.addThread);
    this.collection.bind('remove', this.removeThread);
    this.collection.bind('refresh', this.reload);
  };

  ThreadList.addThread = function(thread, collection) {
    this.el.insert({top: new Teambox.Views.Thread({model:thread}).render().el});
  };

  ThreadList.removeThread = function(thread, collection) {
    this.el.find('.thread[data-class=conversation, data-id='+thread.id+', data-project-id='+thread.get('project_id')+']').remove();
  };

  ThreadList.reload = function(collection) {
    var self = this;
    collection.each(function(model){
      var view = new Teambox.Views.Thread({model:model});
      self.el.insert({bottom: view.render().el});
    });
  };

  ThreadList.render = function () {
    var Views = Teambox.Views, self = this;
    this.el.update('');
    this.reload(this.collection);
    return this;
  };

  // exports
  Teambox.Views.ThreadList = Backbone.View.extend(ThreadList);
}());
