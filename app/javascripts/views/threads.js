Teambox.Views.Activities = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'render');
  },
  render: function() {
    var thread_template = Handlebars.compile(Templates.activities.feed);
    $('content').update(
      thread_template({ threads: this.collection.toJSON() })
    );
  }
});
