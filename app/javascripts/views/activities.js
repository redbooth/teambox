Teambox.Views.Activities = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'render');
  },

  templates: {
    note: {
      create: Handlebars.compile(Templates.activities.note_create),
      edit: Handlebars.compile(Templates.activities.note_edit)
    },
    page: {
      create: Handlebars.compile(Templates.activities.page_create),
      edit: Handlebars.compile(Templates.activities.page_edit)
    },
    tasklist: {
      create: Handlebars.compile(Templates.activities.task_list_create)
    },
    raw_activity: Handlebars.compile(
      "<div class='activity'>activity_{{id}} {{target_type}} {{action}} {{#target}}{{{body_html}}}{{/target}} </div>"
    )
  },

  // Build the activity feed by rendering every thread
  render: function() {
    var self = this;
    $('view_title').update('All your projects');
    $('content').update('');

    // Render each thread
    this.collection.each(function(thread) {
      var template;

      if(thread.get('type') === "Conversation" || thread.get('type') === "Task") {
        // FIXME: This way of creating views could leak memory
        var view = new Teambox.Views.Thread({ model: thread });
        $('content').insert({ bottom: view.render().el });
      } else {
        var name = + "_" + thread.get('action');
        template = (self.templates[thread.get('target_type').toLowerCase()] || {})[thread.get('action')] ||
          self.templates.raw_activity;
        $('content').insert({ bottom: template(thread.toJSON()) });
      }

    });
  }

});
