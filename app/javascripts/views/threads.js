Teambox.Views.Activities = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'render');
  },

  thread_template: Handlebars.compile(Templates.activities.feed),

  render: function() {
    $('content').update(
      this.thread_template({ threads: this.collection.toJSON() })
    );
  }

});
