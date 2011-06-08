(function () {

  var Activities = { tagName: 'div'
                   , id: 'activities'
                   , templates: { project:  { create: Handlebars.compile(Templates.activities.project_create) }
                                , note:     { create: Handlebars.compile(Templates.activities.note_create)
                                            , edit: Handlebars.compile(Templates.activities.note_edit) }
                                , page:     { create: Handlebars.compile(Templates.activities.page_create)
                                            , edit: Handlebars.compile(Templates.activities.page_edit) }
                                , tasklist: { create: Handlebars.compile(Templates.activities.task_list_create) }
                                , raw_activity: Handlebars.compile(
                                    "<div class='activity'>activity_{{id}} {{target_type}} {{action}} {{#target}}{{{body_html}}}{{/target}} </div>"
                                  )
                                }
      };

  Activities.initialize = function (options) {
    _.bindAll(this, 'render');

    this.collection.unbind('add');
    this.collection.bind('add', Activities.appendActivity.bind(this));
    this.collection.bind('no_more_pages', Activities.hidePagination.bind(this));
  };

  Activities.appendActivity = function appendActivity(thread) {
    var template;
    if (thread.get('type') === "Conversation" || thread.get('type') === "Task") {
      this.el.insert({bottom: (new Teambox.Views.Thread({ model: thread })).render().el});
    } else {
      template = (this.templates[thread.get('target_type').toLowerCase()] || {})[thread.get('action')]
        || this.templates.raw_activity;
      this.el.insert({ bottom: template(thread.getAttributes()) });
    }
  };

  Activities.hidePagination = function hidePagination() {
    $('activity_paginate_link').hide();
  };

  // Build the activity feed by rendering every thread
  Activities.render = function () {
    var self = this;

    this.el.update('');
    $('view_title').update('Recent activity');

    // Render each thread
    this.collection.each(function (thread) {
      self.appendActivity(thread);
    });

    $('content').update(this.el);
    $('content').insert({bottom: '<a href="#" class="button" id="activity_paginate_link"><span>Show more</span></a>'});
    $('activity_paginate_link').observe('click', this.collection.fetchNextPage.bind(this.collection));
  };

  // exports
  Teambox.Views.Activities = Backbone.View.extend(Activities);

}());
