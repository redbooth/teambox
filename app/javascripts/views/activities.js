(function () {

  var Activities = { tagName: 'div'
                   , id: 'activities'
                   , templates: { project:  { create: Handlebars.compile(Templates.activities.project_create) }
                                , note:     { create: Handlebars.compile(Templates.activities.note_create)
                                            , edit: Handlebars.compile(Templates.activities.note_edit) }
                                , page:     { create: Handlebars.compile(Templates.activities.page_create)
                                            , edit: Handlebars.compile(Templates.activities.page_edit) }
                                , tasklist: { create: Handlebars.compile(Templates.activities.task_list_create) }
                                , show_more: Teambox.modules.ViewCompiler('partials.show_more')
                                , loading: Teambox.modules.ViewCompiler('partials.loading_img')
                                , raw_activity: Handlebars.compile(
                                    "<div class='activity'>activity_{{id}} {{target_type}} {{action}} {{#target}}{{{body_html}}}{{/target}} </div>"
                                  )
                                }
      };

  Activities.events = {
    'click #activity_paginate_link': 'showMore'
  };

  Activities.initialize = function (options) {
    _.bindAll(this, 'render');

    this.collection.unbind('add');
    this.collection.bind('add', Activities.appendActivity.bind(this));
  };

  Activities.showMore = function showMore(event) {
    var show_more = this.templates.show_more()
    ,  loading = this.templates.loading();

    Element.replace('activity_paginate_link', loading);

    this.collection.fetchNextPage(function (collection, response) {
      Element.replace('activity_paginate_link', show_more);
      var el = $('activity_paginate_link');
      if (response.objects.length <= 50) {
        el.hide();
      }
    });
  };

  Activities.appendActivity = function appendActivity(thread) {
    var template;
    if (thread.get('type') === "Conversation" || thread.get('type') === "Task") {
      this.el.insert({top: (new Teambox.Views.Thread({controller: this.controller, model: thread})).render().el});
    } else if (thread.get('type') === 'Page') {
      this.el.insert({top: (new Teambox.Views.PageTeaser({model: thread})).render().el});
    } else {
      template = (this.templates[thread.get('target_type').toLowerCase()] || {})[thread.get('action')]
        || this.templates.raw_activity;
      this.el.insert({ top: template(thread.getAttributes()) });
    }
  };

  /* Updates the element with each thread
   *
   * @return self
   */
  Activities.render = function () {
    this.el.update('');
    this.collection.models.reverse().each(this.appendActivity.bind(this));
    this.el.insert({bottom: this.templates.show_more()});

    return this;
  };

  // exports
  Teambox.Views.Activities = Backbone.View.extend(Activities);
}());
