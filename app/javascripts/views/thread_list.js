// This view renders a Conversation or Task as a thread
(function () {

  var ThreadList = { tagName: 'div'
               , className: 'threads'
               };

  ThreadList.events = {};

  ThreadList.initialize = function (options) {
    _.bindAll(this, "render");
  };

  ThreadList.render = function () {
    var Views = Teambox.Views, self = this;
    this.el.update('');

    this.collection.each(function(model){
      var view = new Views.Thread({model:model});
      self.el.insert({bottom: view.render().el});
    });

    return this;
  };

  // exports
  Teambox.Views.ThreadList = Backbone.View.extend(ThreadList);
}());
